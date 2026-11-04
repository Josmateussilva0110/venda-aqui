-- Relatórios (lucro do período): o custo do produto passa a ser guardado em cada item da venda,
-- como o preço. Mudar o custo do produto depois não muda o lucro de vendas antigas.

alter table public.sale_items
  add column unit_cost_cents integer not null default 0 check (unit_cost_cents >= 0);

-- Vendas feitas antes desta migration não guardaram o custo: usa o custo atual do produto, que é a
-- melhor estimativa disponível. Itens de produto já excluído ficam com custo zero.
update public.sale_items as i
   set unit_cost_cents = p.cost_price_cents
  from public.products as p
 where p.id = i.product_id
   and p.cost_price_cents <> 0;

-- O mapa de itens mantidos na edição passa a levar preço e custo da época: {"<produto>": {"price": n, "cost": n}}
create or replace function public._sale_apply_items(
  p_merchant_id uuid,
  p_sale_id uuid,
  p_items jsonb,
  p_kept_prices jsonb default '{}'::jsonb
)
returns integer
language plpgsql
set search_path = public
as $$
declare
  v_item record;
  v_product record;
  v_price integer;
  v_cost integer;
  v_subtotal integer;
  v_total integer := 0;
begin
  -- Trava os produtos em ordem de id: duas vendas com os mesmos produtos em ordens diferentes
  -- não se travam mutuamente (deadlock)
  perform 1
     from public.products as p
    where p.merchant_id = p_merchant_id
      and p.id in (select (elem ->> 'productId')::uuid from jsonb_array_elements(p_items) as elem)
    order by p.id
      for update;

  for v_item in
    select (elem ->> 'productId')::uuid as product_id,
           (elem ->> 'quantity')::numeric as quantity,
           ordinality::smallint as position
      from jsonb_array_elements(p_items) with ordinality as t(elem, ordinality)
  loop
    select p.id, p.name, p.sale_price_cents, p.cost_price_cents, p.quantity, p.sold_by_weight
      into v_product
      from public.products as p
     where p.id = v_item.product_id
       and p.merchant_id = p_merchant_id;

    if not found then
      raise exception 'product_not_found' using errcode = 'VQ001', detail = v_item.product_id::text;
    end if;
    if not v_product.sold_by_weight and v_item.quantity <> trunc(v_item.quantity) then
      raise exception 'fractional_quantity' using errcode = 'VQ003', detail = v_product.name;
    end if;
    if v_product.quantity < v_item.quantity then
      raise exception 'insufficient_stock' using errcode = 'VQ002', detail = v_product.name;
    end if;

    v_price := coalesce((p_kept_prices -> v_product.id::text ->> 'price')::integer, v_product.sale_price_cents);
    v_cost := coalesce((p_kept_prices -> v_product.id::text ->> 'cost')::integer, v_product.cost_price_cents);
    v_subtotal := round(v_price * v_item.quantity)::integer;
    v_total := v_total + v_subtotal;

    update public.products set quantity = quantity - v_item.quantity where id = v_product.id;

    insert into public.sale_items (sale_id, product_id, position, name, unit_price_cents, unit_cost_cents, quantity, sold_by_weight, subtotal_cents)
    values (p_sale_id, v_product.id, v_item.position, v_product.name, v_price, v_cost, v_item.quantity, v_product.sold_by_weight, v_subtotal);
  end loop;

  return v_total;
end;
$$;

create or replace function public.update_sale(
  p_merchant_id uuid,
  p_sale_id uuid,
  p_payment_method text,
  p_customer_id uuid,
  p_items jsonb
)
returns table (id uuid, total_cents integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_old record;
  v_kept_prices jsonb;
  v_total integer;
begin
  select s.customer_id, s.total_cents into v_old
    from public.sales as s
   where s.id = p_sale_id and s.merchant_id = p_merchant_id
     for update;

  if not found then
    raise exception 'sale_not_found' using errcode = 'VQ005';
  end if;

  -- Trava, em ordem de id, os produtos da versão antiga e da nova antes de mexer no estoque;
  -- devolver o estoque na ordem dos itens travaria fora de ordem e poderia dar deadlock
  perform 1
     from public.products as p
    where p.merchant_id = p_merchant_id
      and p.id in (
            select i.product_id from public.sale_items as i where i.sale_id = p_sale_id
            union
            select (elem ->> 'productId')::uuid from jsonb_array_elements(p_items) as elem
          )
    order by p.id
      for update;

  select coalesce(jsonb_object_agg(i.product_id, jsonb_build_object('price', i.unit_price_cents, 'cost', i.unit_cost_cents)), '{}'::jsonb)
    into v_kept_prices
    from public.sale_items as i
   where i.sale_id = p_sale_id and i.product_id is not null;

  update public.products as p
     set quantity = p.quantity + i.quantity
    from public.sale_items as i
   where i.sale_id = p_sale_id and p.id = i.product_id;

  delete from public.sale_items where sale_id = p_sale_id;

  v_total := public._sale_apply_items(p_merchant_id, p_sale_id, p_items, v_kept_prices);

  -- Mesmo cliente: aplica só a diferença, senão tirar o total antigo antes de somar o novo
  -- poderia passar por saldo negativo num cliente que já pagou parte
  if v_old.customer_id is not null and v_old.customer_id = p_customer_id then
    perform public._customer_add_balance(p_merchant_id, p_customer_id, v_total - v_old.total_cents);
  else
    if v_old.customer_id is not null then
      perform public._customer_add_balance(p_merchant_id, v_old.customer_id, -v_old.total_cents);
    end if;
    if p_customer_id is not null then
      perform public._customer_add_balance(p_merchant_id, p_customer_id, v_total);
    end if;
  end if;

  update public.sales as s
     set payment_method = p_payment_method,
         customer_id = p_customer_id,
         total_cents = v_total,
         edited_at = now()
   where s.id = p_sale_id;

  return query select p_sale_id, v_total;
end;
$$;

-- Lucro do período: total vendido, custo (da época de cada venda) e os produtos que mais deram lucro.
-- Produto excluído continua no ranking pelo nome guardado no item.
create or replace function public.sales_report(
  p_merchant_id uuid,
  p_from timestamptz,
  p_to timestamptz,
  p_rank_limit integer
)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  with period_sales as (
    select s.id
      from public.sales as s
     where s.merchant_id = p_merchant_id and s.created_at >= p_from and s.created_at < p_to
  ),
  items as (
    select i.product_id, i.name, i.quantity, i.sold_by_weight, i.subtotal_cents,
           round(i.unit_cost_cents * i.quantity)::bigint as cost_cents
      from public.sale_items as i
      join period_sales as ps on ps.id = i.sale_id
  ),
  by_product as (
    select product_id, name, bool_or(sold_by_weight) as sold_by_weight, sum(quantity) as quantity,
           sum(subtotal_cents)::bigint as revenue_cents, sum(subtotal_cents - cost_cents)::bigint as profit_cents
      from items
     group by product_id, name
  )
  select jsonb_build_object(
    'sale_count', (select count(*) from period_sales),
    'revenue_cents', (select coalesce(sum(subtotal_cents), 0) from items),
    'cost_cents', (select coalesce(sum(cost_cents), 0) from items),
    'ranking', coalesce((
      select jsonb_agg(jsonb_build_object(
        'product_id', r.product_id, 'name', r.name, 'sold_by_weight', r.sold_by_weight, 'quantity', r.quantity,
        'revenue_cents', r.revenue_cents, 'profit_cents', r.profit_cents
      ) order by r.profit_cents desc, r.name)
        from (select * from by_product order by profit_cents desc, name limit p_rank_limit) as r
    ), '[]'::jsonb)
  );
$$;

revoke execute on function public._sale_apply_items(uuid, uuid, jsonb, jsonb) from public, anon, authenticated;
revoke execute on function public.update_sale(uuid, uuid, text, uuid, jsonb) from public, anon, authenticated;
revoke execute on function public.sales_report(uuid, timestamptz, timestamptz, integer) from public, anon, authenticated;
grant execute on function public.update_sale(uuid, uuid, text, uuid, jsonb) to service_role;
grant execute on function public.sales_report(uuid, timestamptz, timestamptz, integer) to service_role;
