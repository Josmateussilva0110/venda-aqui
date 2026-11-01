-- Resumo do fiado (quantos devem e quanto há para receber), mostrado no início e no topo da
-- lista de devedores. A lista é paginada, então o app não consegue somar sozinho.

-- Atende a soma abaixo e a lista filtrada em "devendo" (ordenada por nome) sem varrer quem está em dia
create index customers_owing_idx on public.customers (merchant_id, name, id) where balance_cents > 0;

create or replace function public.customer_credit_summary(p_merchant_id uuid)
returns table (owing_count integer, owed_cents bigint)
language sql
stable
security definer
set search_path = public
as $$
  select count(*)::integer, coalesce(sum(c.balance_cents), 0)::bigint
    from public.customers as c
   where c.merchant_id = p_merchant_id and c.balance_cents > 0;
$$;

revoke execute on function public.customer_credit_summary(uuid) from public, anon, authenticated;
grant execute on function public.customer_credit_summary(uuid) to service_role;
