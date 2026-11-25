-- Portal do cliente: as movimentações passam a trazer os itens de cada compra.
-- Função própria do portal (não mexe em customer_statement, que o app do comerciante usa): confere que o
-- cadastro é da conta e já pagina na mesma ida ao banco. Devolve nulo quando a loja não é dessa conta.

create or replace function public.customer_portal_statement(
  p_account_id uuid,
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
  with store as (
    select c.id, c.merchant_id
      from public.customers as c
     where c.id = p_customer_id and c.portal_account_id = p_account_id
  ),
  entries as (
    select 'sale' as kind, s.id, s.total_cents as amount_cents, s.payment_method, s.created_at
      from public.sales as s, store
     where s.customer_id = store.id and s.merchant_id = store.merchant_id
    union all
    select 'payment', p.id, p.amount_cents, p.payment_method, p.created_at
      from public.customer_payments as p, store
     where p.customer_id = store.id and p.merchant_id = store.merchant_id
  ),
  page as (
    select * from entries order by created_at desc, id desc limit p_limit offset p_offset
  )
  select jsonb_build_object(
    'total', (select count(*) from entries),
    'items', coalesce((
      select jsonb_agg(jsonb_build_object(
        'kind', pg.kind, 'id', pg.id, 'amount_cents', pg.amount_cents, 'payment_method', pg.payment_method,
        'created_at', pg.created_at,
        -- Valor de cada item como ficou gravado na venda (preço da época); pagamento não tem itens
        'items', case when pg.kind = 'sale' then (
          select coalesce(jsonb_agg(jsonb_build_object(
            'name', i.name, 'quantity', i.quantity, 'sold_by_weight', i.sold_by_weight, 'subtotal_cents', i.subtotal_cents
          ) order by i.position), '[]'::jsonb)
            from public.sale_items as i
           where i.sale_id = pg.id
        ) else '[]'::jsonb end
      ) order by pg.created_at desc, pg.id desc) from page as pg
    ), '[]'::jsonb)
  )
  where exists (select 1 from store);
$$;

revoke execute on function public.customer_portal_statement(uuid, uuid, integer, integer) from public, anon, authenticated;
grant execute on function public.customer_portal_statement(uuid, uuid, integer, integer) to service_role;
