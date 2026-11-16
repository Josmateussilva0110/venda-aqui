-- Vendas registradas sem internet e enviadas depois pelo app.
-- client_id: gerado no aparelho; reenviar a mesma venda (resposta perdida, app fechado no meio) não duplica.
-- sold_at: quando a venda aconteceu no balcão, não quando chegou ao servidor.
-- Venda offline com estoque que já acabou é aceita: a venda já aconteceu, o estoque vai a zero e a falta
-- volta na resposta para o app avisar. Online o servidor continua recusando (o comerciante vê o estoque na hora).

alter table public.sales add column client_id uuid;

create unique index sales_merchant_client_id_key on public.sales (merchant_id, client_id) where client_id is not null;

-- Mesma função, com p_allow_shortfall: o parâmetro novo tem default, então update_sale continua chamando
-- com 4 argumentos. A versão antiga sai antes para a chamada não ficar ambígua.
drop function public._sale_apply_items(uuid, uuid, jsonb, jsonb);

create function public._sale_apply_items(
  p_merchant_id uuid,
  p_sale_id uuid,
  p_items jsonb,
  p_kept_prices jsonb default '{}'::jsonb,
  p_allow_shortfall boolean default false
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
    if v_product.quantity < v_item.quantity and not p_allow_shortfall then
      raise exception 'insufficient_stock' using errcode = 'VQ002', detail = v_product.name;
    end if;

    v_price := coalesce((p_kept_prices -> v_product.id::text ->> 'price')::integer, v_product.sale_price_cents);
    v_cost := coalesce((p_kept_prices -> v_product.id::text ->> 'cost')::integer, v_product.cost_price_cents);
    v_subtotal := round(v_price * v_item.quantity)::integer;
    v_total := v_total + v_subtotal;

    -- Com falta aceita o estoque para em zero (a constraint não aceita negativo); a venda guarda a quantidade real
    update public.products set quantity = greatest(quantity - v_item.quantity, 0) where id = v_product.id;

    insert into public.sale_items (sale_id, product_id, position, name, unit_price_cents, unit_cost_cents, quantity, sold_by_weight, subtotal_cents)
    values (p_sale_id, v_product.id, v_item.position, v_product.name, v_price, v_cost, v_item.quantity, v_product.sold_by_weight, v_subtotal);
  end loop;

  return v_total;
end;
$$;

-- O retorno ganhou colunas: precisa sair e entrar de novo
drop function public.register_sale(uuid, text, uuid, jsonb);

create function public.register_sale(
  p_merchant_id uuid,
  p_payment_method text,
  p_customer_id uuid,
  p_items jsonb,
  p_client_id uuid default null,
  p_sold_at timestamptz default null
)
returns table (id uuid, total_cents integer, stock_shortfalls jsonb, replayed boolean)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_sale_id uuid;
  v_total integer;
  v_offline boolean := p_sold_at is not null;
  v_shortfalls jsonb := '[]'::jsonb;
begin
  -- Reenvio da mesma venda: devolve a que já foi gravada, sem mexer de novo em estoque e saldo
  if p_client_id is not null then
    select s.id, s.total_cents into v_sale_id, v_total
      from public.sales as s
     where s.merchant_id = p_merchant_id and s.client_id = p_client_id;
    if found then
      return query select v_sale_id, v_total, '[]'::jsonb, true;
      return;
    end if;
  end if;

  -- Antes do insert: sem isso, cliente de outro comércio cairia na chave estrangeira (23503)
  -- em vez do erro de cliente não encontrado
  if p_customer_id is not null then
    perform 1 from public.customers as c where c.id = p_customer_id and c.merchant_id = p_merchant_id;
    if not found then
      raise exception 'customer_not_found' using errcode = 'VQ004';
    end if;
  end if;

  -- Total provisório: a constraint de total não aceita nulo e o valor real só sai dos itens.
  -- Relógio do aparelho adiantado não cria venda no futuro.
  insert into public.sales (merchant_id, customer_id, payment_method, total_cents, client_id, created_at)
  values (p_merchant_id, p_customer_id, p_payment_method, 0, p_client_id, coalesce(least(p_sold_at, now()), now()))
  on conflict (merchant_id, client_id) where client_id is not null do nothing
  returning sales.id into v_sale_id;

  -- Dois envios simultâneos da mesma venda: o índice único fez este esperar o outro terminar
  if v_sale_id is null then
    select s.id, s.total_cents into v_sale_id, v_total
      from public.sales as s
     where s.merchant_id = p_merchant_id and s.client_id = p_client_id;
    return query select v_sale_id, v_total, '[]'::jsonb, true;
    return;
  end if;

  if v_offline then
    -- Trava antes, na mesma ordem de id de _sale_apply_items (que trava de novo sem custo), para a
    -- falta lida aqui ser a mesma que a baixa do estoque vai encontrar
    perform 1
       from public.products as p
      where p.merchant_id = p_merchant_id
        and p.id in (select (elem ->> 'productId')::uuid from jsonb_array_elements(p_items) as elem)
      order by p.id
        for update;

    select coalesce(jsonb_agg(jsonb_build_object(
             'productId', p.id,
             'name', p.name,
             'missingQuantity', item.quantity - p.quantity
           ) order by p.name), '[]'::jsonb)
      into v_shortfalls
      from (
        select (elem ->> 'productId')::uuid as product_id, (elem ->> 'quantity')::numeric as quantity
          from jsonb_array_elements(p_items) as elem
      ) as item
      join public.products as p on p.id = item.product_id and p.merchant_id = p_merchant_id
     where p.quantity < item.quantity;
  end if;

  v_total := public._sale_apply_items(p_merchant_id, v_sale_id, p_items, '{}'::jsonb, v_offline);
  update public.sales set total_cents = v_total where sales.id = v_sale_id;

  if p_customer_id is not null then
    perform public._customer_add_balance(p_merchant_id, p_customer_id, v_total);
  end if;

  return query select v_sale_id, v_total, v_shortfalls, false;
end;
$$;

revoke execute on function public._sale_apply_items(uuid, uuid, jsonb, jsonb, boolean) from public, anon, authenticated;
revoke execute on function public.register_sale(uuid, text, uuid, jsonb, uuid, timestamptz) from public, anon, authenticated;
grant execute on function public.register_sale(uuid, text, uuid, jsonb, uuid, timestamptz) to service_role;
