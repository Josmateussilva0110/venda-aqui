-- Reposição de estoque: soma no banco, numa instrução só, para duas reposições
-- simultâneas (ou uma reposição junto de uma venda, na Iteração 2) não se sobrescreverem.
-- Devolve o id quando o produto existe e é do comerciante; nenhuma linha caso contrário.
-- Quantidade fracionada em produto por unidade cai na constraint products_unit_quantity_is_integer.

create or replace function public.restock_product(
  p_merchant_id uuid,
  p_product_id uuid,
  p_quantity numeric
)
returns table (id uuid)
language sql
security definer
set search_path = public
as $$
  update public.products as p
     set quantity = p.quantity + p_quantity
   where p.id = p_product_id
     and p.merchant_id = p_merchant_id
  returning p.id;
$$;

revoke execute on function public.restock_product(uuid, uuid, numeric) from public, anon, authenticated;
grant execute on function public.restock_product(uuid, uuid, numeric) to service_role;

-- Filtros de estoque (baixo/esgotado) consultam por quantidade dentro do comerciante
create index if not exists products_merchant_quantity_idx on public.products (merchant_id, quantity);
