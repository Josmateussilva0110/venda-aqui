-- Iteração 2: vendas gravadas no servidor e fiado (RF de vendas e de clientes).
-- Tudo que mexe em estoque ou saldo passa por função SQL: a venda, os itens, a baixa de estoque
-- e o saldo do cliente mudam na mesma transação, ou nada muda. O total é sempre calculado aqui,
-- a partir do preço do produto; o app nunca envia preço nem total.
--
-- Erros de regra saem com SQLSTATE próprio (classe VQ), que a API traduz para códigos de erro:
--   VQ001 produto não encontrado      VQ004 cliente não encontrado
--   VQ002 estoque insuficiente        VQ005 venda não encontrada
--   VQ003 fração em produto unitário  VQ006 saldo do cliente ficaria negativo
-- Em VQ001/VQ002/VQ003 o DETAIL leva o nome do produto, para a mensagem dizer qual foi.

-- Clientes ---------------------------------------------------------------------------

-- Quanto o cliente deve agora: soma das vendas fiado menos os pagamentos. Guardado na linha
-- (e não somado a cada leitura) para a lista ordenar e filtrar devedores sem varrer o histórico;
-- só as funções abaixo alteram, sempre na mesma transação do lançamento.
alter table public.customers
  add column balance_cents integer not null default 0,
  add constraint customers_balance_not_negative check (balance_cents >= 0);

-- Permite chave estrangeira composta (id, merchant_id): venda ou pagamento nunca apontam
-- para cliente de outro comércio, nem por bug na API
alter table public.customers add constraint customers_id_merchant_key unique (id, merchant_id);

-- Vendas -----------------------------------------------------------------------------

create table public.sales (
  id             uuid primary key default gen_random_uuid(),
  merchant_id    uuid not null references public.merchants (id) on delete cascade,
  customer_id    uuid,
  payment_method text not null check (payment_method in ('cash', 'pix', 'card', 'credit')),
  total_cents    integer not null check (total_cents >= 0),
  created_at     timestamptz not null default now(),
  edited_at      timestamptz,
  -- Fiado sempre tem cliente; as outras formas nunca têm
  constraint sales_credit_has_customer check ((payment_method = 'credit') = (customer_id is not null)),
  -- restrict: cliente com venda no histórico não pode ser apagado (a dívida sumiria)
  constraint sales_customer_fkey foreign key (customer_id, merchant_id)
    references public.customers (id, merchant_id) on delete restrict
);

-- Histórico: vendas do comerciante por período, da mais recente para a mais antiga
create index sales_merchant_created_idx on public.sales (merchant_id, created_at desc, id desc);
-- Extrato do cliente
create index sales_customer_created_idx on public.sales (customer_id, created_at desc) where customer_id is not null;

create table public.sale_items (
  id               uuid primary key default gen_random_uuid(),
  sale_id          uuid not null references public.sales (id) on delete cascade,
  -- set null: apagar o produto não apaga a venda; nome e preço ficam guardados no item
  product_id       uuid references public.products (id) on delete set null,
  position         smallint not null,
  name             text not null,
  unit_price_cents integer not null check (unit_price_cents >= 0),
  quantity         numeric(12, 3) not null check (quantity > 0),
  sold_by_weight   boolean not null,
  subtotal_cents   integer not null check (subtotal_cents >= 0),
  constraint sale_items_sale_position_key unique (sale_id, position)
);

create index sale_items_sale_idx on public.sale_items (sale_id);
-- Apagar um produto anula o product_id dos itens (set null); sem índice seria uma varredura
-- de todos os itens da plataforma a cada produto apagado
create index sale_items_product_idx on public.sale_items (product_id) where product_id is not null;

-- A busca do histórico procura o nome do produto dentro dos itens ("%arroz%"), que um índice
-- comum não atende; o trigram atende ilike com curinga dos dois lados
create schema if not exists extensions;
create extension if not exists pg_trgm with schema extensions;
create index sale_items_name_trgm_idx on public.sale_items using gin (name extensions.gin_trgm_ops);

-- Pagamentos do fiado ---------------------------------------------------------------

create table public.customer_payments (
  id             uuid primary key default gen_random_uuid(),
  merchant_id    uuid not null references public.merchants (id) on delete cascade,
  customer_id    uuid not null,
  amount_cents   integer not null check (amount_cents > 0),
  payment_method text not null check (payment_method in ('cash', 'pix', 'card')),
  created_at     timestamptz not null default now(),
  constraint customer_payments_customer_fkey foreign key (customer_id, merchant_id)
    references public.customers (id, merchant_id) on delete restrict
);

create index customer_payments_customer_created_idx on public.customer_payments (customer_id, created_at desc);

alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.customer_payments enable row level security;

-- Funções internas ---------------------------------------------------------------------

-- Grava os itens, baixa o estoque e devolve o total. p_items: [{"productId": uuid, "quantity": n}].
-- p_kept_prices mantém o preço original dos produtos que já estavam na venda editada.
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
    select p.id, p.name, p.sale_price_cents, p.quantity, p.sold_by_weight
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

    v_price := coalesce((p_kept_prices ->> v_product.id::text)::integer, v_product.sale_price_cents);
    v_subtotal := round(v_price * v_item.quantity)::integer;
    v_total := v_total + v_subtotal;

    update public.products set quantity = quantity - v_item.quantity where id = v_product.id;

    insert into public.sale_items (sale_id, product_id, position, name, unit_price_cents, quantity, sold_by_weight, subtotal_cents)
    values (p_sale_id, v_product.id, v_item.position, v_product.name, v_price, v_item.quantity, v_product.sold_by_weight, v_subtotal);
  end loop;

  return v_total;
end;
$$;

-- Soma p_delta ao saldo do cliente; saldo negativo (pagou mais do que deve) é recusado com VQ006
create or replace function public._customer_add_balance(p_merchant_id uuid, p_customer_id uuid, p_delta integer)
returns integer
language plpgsql
set search_path = public
as $$
declare
  v_balance integer;
begin
  select balance_cents into v_balance
    from public.customers
   where id = p_customer_id and merchant_id = p_merchant_id
     for update;

  if not found then
    raise exception 'customer_not_found' using errcode = 'VQ004';
  end if;
  if v_balance + p_delta < 0 then
    raise exception 'negative_balance' using errcode = 'VQ006';
  end if;

  update public.customers set balance_cents = v_balance + p_delta where id = p_customer_id;
  return v_balance + p_delta;
end;
$$;

-- Funções chamadas pela API ------------------------------------------------------------

create or replace function public.register_sale(
  p_merchant_id uuid,
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
  v_sale_id uuid;
  v_total integer;
begin
  -- Antes do insert: sem isso, cliente de outro comércio cairia na chave estrangeira (23503)
  -- em vez do erro de cliente não encontrado
  if p_customer_id is not null then
    perform 1 from public.customers as c where c.id = p_customer_id and c.merchant_id = p_merchant_id;
    if not found then
      raise exception 'customer_not_found' using errcode = 'VQ004';
    end if;
  end if;

  -- Total provisório: a constraint de total não aceita nulo e o valor real só sai dos itens
  insert into public.sales (merchant_id, customer_id, payment_method, total_cents)
  values (p_merchant_id, p_customer_id, p_payment_method, 0)
  returning sales.id into v_sale_id;

  v_total := public._sale_apply_items(p_merchant_id, v_sale_id, p_items);
  update public.sales set total_cents = v_total where sales.id = v_sale_id;

  if p_customer_id is not null then
    perform public._customer_add_balance(p_merchant_id, p_customer_id, v_total);
  end if;

  return query select v_sale_id, v_total;
end;
$$;

-- Edição: devolve ao estoque e ao saldo o que a venda tinha e aplica a versão nova.
-- Itens que continuam na venda mantêm o preço da época; produtos novos entram pelo preço atual.
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

  select coalesce(jsonb_object_agg(i.product_id, i.unit_price_cents), '{}'::jsonb) into v_kept_prices
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

create or replace function public.register_customer_payment(
  p_merchant_id uuid,
  p_customer_id uuid,
  p_amount_cents integer,
  p_payment_method text
)
returns table (id uuid, balance_cents integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_payment_id uuid;
  v_balance integer;
begin
  -- Antes do insert: o saldo trava o cliente e recusa pagamento maior que a dívida
  v_balance := public._customer_add_balance(p_merchant_id, p_customer_id, -p_amount_cents);

  insert into public.customer_payments (merchant_id, customer_id, amount_cents, payment_method)
  values (p_merchant_id, p_customer_id, p_amount_cents, p_payment_method)
  returning customer_payments.id into v_payment_id;

  return query select v_payment_id, v_balance;
end;
$$;

-- Venda no formato que a API lê (o mesmo no histórico e no detalhe), com itens e cliente
create or replace function public._sale_json(p_sale_id uuid)
returns jsonb
language sql
stable
set search_path = public
as $$
  select jsonb_build_object(
    'id', s.id,
    'payment_method', s.payment_method,
    'total_cents', s.total_cents,
    'created_at', s.created_at,
    'edited_at', s.edited_at,
    'customer', case when c.id is null then null else jsonb_build_object('id', c.id, 'name', c.name) end,
    'items', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'product_id', i.product_id,
        'name', i.name,
        'unit_price_cents', i.unit_price_cents,
        'quantity', i.quantity,
        'sold_by_weight', i.sold_by_weight,
        'subtotal_cents', i.subtotal_cents
      ) order by i.position), '[]'::jsonb)
        from public.sale_items as i
       where i.sale_id = s.id
    )
  )
    from public.sales as s
    left join public.customers as c on c.id = s.customer_id
   where s.id = p_sale_id;
$$;

-- Nulo quando a venda não existe ou é de outro comerciante
create or replace function public.get_sale(p_merchant_id uuid, p_sale_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select public._sale_json(s.id) from public.sales as s where s.id = p_sale_id and s.merchant_id = p_merchant_id;
$$;

-- Histórico paginado com o resumo do período (quantidade e soma), que o app não consegue
-- calcular sozinho quando só tem uma página. A busca procura o nome do produto nos itens.
-- O filtro é montado só com o que foi pedido: com "p_search is null or ..." fixo na consulta o
-- plano genérico da função testava a busca venda a venda (medido: ~450 ms num ano de vendas).
-- Os valores entram só por USING, nunca concatenados no texto da consulta.
create or replace function public.list_sales(
  p_merchant_id uuid,
  p_from timestamptz,
  p_to timestamptz,
  p_payment_method text,
  p_search text,
  p_limit integer,
  p_offset integer
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_where text := 's.merchant_id = $1 and s.created_at >= $2 and s.created_at < $3';
  v_total integer;
  v_total_cents bigint;
  v_items jsonb;
begin
  if p_payment_method is not null then
    v_where := v_where || ' and s.payment_method = $4';
  end if;
  if p_search is not null then
    v_where := v_where || ' and s.id in (select i.sale_id from public.sale_items as i where i.name ilike ''%'' || $5 || ''%'')';
  end if;

  execute format('select count(*), coalesce(sum(s.total_cents), 0) from public.sales as s where %s', v_where)
     into v_total, v_total_cents
    using p_merchant_id, p_from, p_to, p_payment_method, p_search;

  execute format(
    'select coalesce(jsonb_agg(public._sale_json(page.id) order by page.created_at desc, page.id desc), ''[]''::jsonb)
       from (select s.id, s.created_at from public.sales as s where %s
              order by s.created_at desc, s.id desc limit $6 offset $7) as page',
    v_where
  )
     into v_items
    using p_merchant_id, p_from, p_to, p_payment_method, p_search, p_limit, p_offset;

  return jsonb_build_object('total', v_total, 'total_cents', v_total_cents, 'items', v_items);
end;
$$;

-- Extrato do fiado: vendas a prazo e pagamentos do cliente, do mais recente para o mais antigo
create or replace function public.customer_statement(
  p_merchant_id uuid,
  p_customer_id uuid,
  p_limit integer,
  p_offset integer
)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  with entries as (
    select 'sale' as kind, s.id, s.total_cents as amount_cents, s.payment_method, s.created_at
      from public.sales as s
     where s.customer_id = p_customer_id and s.merchant_id = p_merchant_id
    union all
    select 'payment', p.id, p.amount_cents, p.payment_method, p.created_at
      from public.customer_payments as p
     where p.customer_id = p_customer_id and p.merchant_id = p_merchant_id
  ),
  page as (
    select * from entries order by created_at desc, id desc limit p_limit offset p_offset
  )
  select jsonb_build_object(
    'total', (select count(*) from entries),
    'items', coalesce((
      select jsonb_agg(jsonb_build_object(
        'kind', kind, 'id', id, 'amount_cents', amount_cents, 'payment_method', payment_method, 'created_at', created_at
      ) order by created_at desc, id desc) from page
    ), '[]'::jsonb)
  );
$$;

-- Acesso ------------------------------------------------------------------------------
-- Só a API (service_role) chama as funções públicas; as internas (prefixo _) rodam
-- apenas de dentro delas, que são security definer.

revoke execute on function public._sale_apply_items(uuid, uuid, jsonb, jsonb) from public, anon, authenticated;
revoke execute on function public._customer_add_balance(uuid, uuid, integer) from public, anon, authenticated;
revoke execute on function public._sale_json(uuid) from public, anon, authenticated;

revoke execute on function public.register_sale(uuid, text, uuid, jsonb) from public, anon, authenticated;
revoke execute on function public.update_sale(uuid, uuid, text, uuid, jsonb) from public, anon, authenticated;
revoke execute on function public.register_customer_payment(uuid, uuid, integer, text) from public, anon, authenticated;
revoke execute on function public.get_sale(uuid, uuid) from public, anon, authenticated;
revoke execute on function public.list_sales(uuid, timestamptz, timestamptz, text, text, integer, integer) from public, anon, authenticated;
revoke execute on function public.customer_statement(uuid, uuid, integer, integer) from public, anon, authenticated;

grant execute on function public.register_sale(uuid, text, uuid, jsonb) to service_role;
grant execute on function public.update_sale(uuid, uuid, text, uuid, jsonb) to service_role;
grant execute on function public.register_customer_payment(uuid, uuid, integer, text) to service_role;
grant execute on function public.get_sale(uuid, uuid) to service_role;
grant execute on function public.list_sales(uuid, timestamptz, timestamptz, text, text, integer, integer) to service_role;
grant execute on function public.customer_statement(uuid, uuid, integer, integer) to service_role;
