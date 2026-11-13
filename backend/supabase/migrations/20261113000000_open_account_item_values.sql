-- A cobrança pelo WhatsApp passa a mostrar o valor de cada item (formato "itens com valor").
-- Só troca a função customer_open_account (20261112000000_customer_open_account.sql) para incluir
-- subtotal_cents em cada item; tabelas, dados e permissões não mudam (create or replace mantém os grants).

create or replace function public.customer_open_account(p_merchant_id uuid, p_customer_id uuid, p_limit integer)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  with customer as (
    select c.id, c.balance_cents, c.credit_due_date
      from public.customers as c
     where c.id = p_customer_id and c.merchant_id = p_merchant_id
  ),
  entries as (
    select 'sale' as kind, s.id, s.created_at, s.total_cents as delta
      from public.sales as s
     where s.customer_id = p_customer_id and s.merchant_id = p_merchant_id
    union all
    select 'payment', p.id, p.created_at, -p.amount_cents
      from public.customer_payments as p
     where p.customer_id = p_customer_id and p.merchant_id = p_merchant_id
  ),
  running as (
    select e.*,
           row_number() over (order by e.created_at, e.id) as position,
           sum(e.delta) over (order by e.created_at, e.id rows unbounded preceding) as balance_after
      from entries as e
  ),
  -- Último lançamento que deixou a conta zerada; o que vem depois é a dívida atual
  last_zero as (
    select coalesce(max(position), 0) as position from running where balance_after <= 0
  ),
  open_entries as (
    select r.* from running as r, last_zero as z where r.position > z.position
  ),
  purchases as (
    select o.id, o.created_at, o.delta as total_cents,
           row_number() over (order by o.created_at desc, o.id desc) as recency
      from open_entries as o
     where o.kind = 'sale'
  )
  select jsonb_build_object(
    'balance_cents', c.balance_cents,
    'credit_due_date', c.credit_due_date,
    'paid_cents', coalesce((select -sum(delta) from open_entries where kind = 'payment'), 0),
    -- As mais recentes, em ordem de data; as mais antigas viram só contagem e soma
    'purchases', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', p.id,
        'created_at', p.created_at,
        'total_cents', p.total_cents,
        'items', (
          select coalesce(jsonb_agg(jsonb_build_object(
            'name', i.name, 'quantity', i.quantity, 'sold_by_weight', i.sold_by_weight,
            -- Valor do item como ficou gravado na venda (preço da época); a soma fecha com o total da compra
            'subtotal_cents', i.subtotal_cents
          ) order by i.position), '[]'::jsonb)
            from public.sale_items as i
           where i.sale_id = p.id
        )
      ) order by p.created_at, p.id)
        from purchases as p
       where p.recency <= p_limit
    ), '[]'::jsonb),
    'earlier_count', (select count(*) from purchases where recency > p_limit),
    'earlier_cents', coalesce((select sum(total_cents) from purchases where recency > p_limit), 0)
  )
    from customer as c;
$$;
