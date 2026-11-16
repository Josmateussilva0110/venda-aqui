-- Pagamentos de fiado e reposições de estoque feitos sem internet e enviados depois pelo app.
-- Mesma ideia das vendas (20261116000000_offline_sales.sql): client_id gerado no aparelho torna o reenvio
-- seguro. O pagamento guarda a hora em que o dinheiro foi recebido (paid_at); a reposição não precisa.
-- Pagamento maior que a dívida continua recusado também offline: o comerciante resolve olhando o extrato.

alter table public.customer_payments add column client_id uuid;

create unique index customer_payments_merchant_client_id_key
  on public.customer_payments (merchant_id, client_id) where client_id is not null;

-- Registro das reposições: guarda o client_id (reenvio) e serve de histórico de entradas no estoque
create table public.product_restocks (
  id          uuid primary key default gen_random_uuid(),
  merchant_id uuid not null references public.merchants (id) on delete cascade,
  product_id  uuid not null references public.products (id) on delete cascade,
  client_id   uuid not null,
  quantity    numeric(12, 3) not null check (quantity > 0),
  created_at  timestamptz not null default now(),
  constraint product_restocks_merchant_client_id_key unique (merchant_id, client_id)
);

create index product_restocks_product_created_idx on public.product_restocks (product_id, created_at desc);

alter table public.product_restocks enable row level security;

-- O pagamento agora grava antes de mexer no saldo, e o insert com chave estrangeira pega KEY SHARE no cliente.
-- Com FOR UPDATE aqui, dois pagamentos (ou pagamento e venda fiado) do mesmo cliente ao mesmo tempo pegavam
-- KEY SHARE juntos e cada um esperava o outro para subir o lock: deadlock. NO KEY UPDATE basta (o update só
-- mexe no saldo, que não é chave), não conflita com KEY SHARE e continua enfileirando quem mexe no saldo.
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
     for no key update;

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

-- O retorno ganhou colunas: precisa sair e entrar de novo
drop function public.register_customer_payment(uuid, uuid, integer, text);

create function public.register_customer_payment(
  p_merchant_id uuid,
  p_customer_id uuid,
  p_amount_cents integer,
  p_payment_method text,
  p_client_id uuid default null,
  p_paid_at timestamptz default null
)
returns table (id uuid, balance_cents integer, replayed boolean)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_payment_id uuid;
  v_balance integer;
begin
  -- Antes do insert: sem isso, cliente de outro comércio cairia na chave estrangeira (23503)
  perform 1 from public.customers as c where c.id = p_customer_id and c.merchant_id = p_merchant_id;
  if not found then
    raise exception 'customer_not_found' using errcode = 'VQ004';
  end if;

  -- O pagamento entra antes do saldo: dois envios simultâneos do mesmo client_id se encontram no índice
  -- único aqui, e só o primeiro chega a mexer no saldo. Se o saldo recusar, a transação desfaz o insert.
  insert into public.customer_payments (merchant_id, customer_id, amount_cents, payment_method, client_id, created_at)
  values (p_merchant_id, p_customer_id, p_amount_cents, p_payment_method, p_client_id, coalesce(least(p_paid_at, now()), now()))
  on conflict (merchant_id, client_id) where client_id is not null do nothing
  returning customer_payments.id into v_payment_id;

  -- Reenvio do mesmo pagamento: devolve o que já foi gravado e o saldo de agora
  if v_payment_id is null then
    select cp.id into v_payment_id
      from public.customer_payments as cp
     where cp.merchant_id = p_merchant_id and cp.client_id = p_client_id;
    select c.balance_cents into v_balance from public.customers as c where c.id = p_customer_id;
    return query select v_payment_id, v_balance, true;
    return;
  end if;

  -- Trava o cliente e recusa pagamento maior que a dívida (VQ006)
  v_balance := public._customer_add_balance(p_merchant_id, p_customer_id, -p_amount_cents);

  return query select v_payment_id, v_balance, false;
end;
$$;

drop function public.restock_product(uuid, uuid, numeric);

-- Devolve o id quando o produto existe e é do comerciante; nenhuma linha caso contrário.
-- Quantidade fracionada em produto por unidade cai na constraint products_unit_quantity_is_integer.
create function public.restock_product(
  p_merchant_id uuid,
  p_product_id uuid,
  p_quantity numeric,
  p_client_id uuid default null
)
returns table (id uuid, replayed boolean)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_restock_id uuid;
begin
  if p_client_id is not null then
    -- O registro entra antes da soma, pelo mesmo motivo do pagamento: o reenvio para no índice único
    insert into public.product_restocks (merchant_id, product_id, client_id, quantity)
    select p_merchant_id, p.id, p_client_id, p_quantity
      from public.products as p
     where p.id = p_product_id and p.merchant_id = p_merchant_id
    on conflict (merchant_id, client_id) do nothing
    returning product_restocks.id into v_restock_id;

    if v_restock_id is null then
      -- Ou já foi aplicada (reenvio), ou o produto não existe / é de outro comércio (nenhuma linha)
      if exists (select 1 from public.product_restocks as r where r.merchant_id = p_merchant_id and r.client_id = p_client_id) then
        return query select p_product_id, true;
      end if;
      return;
    end if;
  end if;

  -- Soma no banco, numa instrução só, para reposição e venda simultâneas não se sobrescreverem
  return query
    update public.products as p
       set quantity = p.quantity + p_quantity
     where p.id = p_product_id
       and p.merchant_id = p_merchant_id
    returning p.id, false;
end;
$$;

revoke execute on function public.register_customer_payment(uuid, uuid, integer, text, uuid, timestamptz) from public, anon, authenticated;
revoke execute on function public.restock_product(uuid, uuid, numeric, uuid) from public, anon, authenticated;
grant execute on function public.register_customer_payment(uuid, uuid, integer, text, uuid, timestamptz) to service_role;
grant execute on function public.restock_product(uuid, uuid, numeric, uuid) to service_role;
