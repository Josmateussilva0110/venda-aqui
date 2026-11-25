-- Portal do cliente: o cliente consulta as próprias compras e pagamentos, agrupados por loja.
--
-- A conta do cliente é o telefone + um PIN que ele mesmo cria. Uma loja só aparece na consulta depois
-- que ela própria envia um convite (link de uso único pelo WhatsApp do comerciante) e o cliente o abre:
-- é o comerciante confirmando "essa pessoa é minha cliente". O CPF serve para entrar, mas nunca junta
-- lojas sozinho, porque é o comerciante quem digita: juntar por CPF deixaria um comércio cadastrar o CPF
-- de outra pessoa e ver as compras dela nas outras lojas.
--
-- O comerciante vê o link que envia, então o convite não pode dar acesso ao que outras lojas ligaram:
--   * conta nova: o convite cria a conta com um PIN novo;
--   * conta existente: ou quem abre informa o PIN atual (só liga a loja), ou cria um PIN novo, e aí as
--     outras lojas são desligadas e as sessões encerradas (voltam quando cada uma enviar um convite novo).
-- Assim toda loja visível numa conta foi ligada por alguém que sabia o PIN daquele momento.
--
-- Erros de regra (classe VQ, como nas vendas):
--   VQ009 convite inválido, expirado, já usado ou telefone do cliente mudou desde o envio
--   VQ010 conta ainda não existe e não veio PIN novo para criá-la

-- Contas -----------------------------------------------------------------------------

create table public.customer_accounts (
  id                  uuid primary key default gen_random_uuid(),
  -- Mesmo formato de customers.phone, para casar a conta com o cadastro de cada loja
  phone               text not null unique,
  pin_hash            text not null,
  failed_pin_attempts integer not null default 0 check (failed_pin_attempts >= 0),
  pin_locked_until    timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint customer_accounts_phone_format check (phone ~ '^\+55[0-9]{10,11}$')
);

create trigger customer_accounts_set_updated_at
before update on public.customer_accounts
for each row execute function public.set_updated_at();

-- Loja ligada à conta: o cadastro do cliente naquela loja aponta para a conta
alter table public.customers
  add column portal_account_id uuid references public.customer_accounts (id) on delete set null;

create index customers_portal_account_idx on public.customers (portal_account_id) where portal_account_id is not null;
-- Entrada pelo CPF: procura só entre cadastros já ligados a uma conta
create index customers_portal_cpf_idx on public.customers (cpf) where portal_account_id is not null and cpf is not null;

-- Telefone trocado pelo comerciante desliga a loja: a conta é do dono do número antigo, e o
-- histórico não pode passar a aparecer para outra pessoa nem continuar com quem não é mais o cliente
create or replace function public.customers_unlink_portal_on_phone_change()
returns trigger
language plpgsql
as $$
begin
  if new.phone is distinct from old.phone then
    new.portal_account_id = null;
  end if;
  return new;
end;
$$;

create trigger customers_unlink_portal_on_phone_change
before update of phone on public.customers
for each row execute function public.customers_unlink_portal_on_phone_change();

-- Sessões (uma por aparelho ou navegador), separadas das do comerciante ----------------

create table public.customer_sessions (
  id                 uuid primary key default gen_random_uuid(),
  account_id         uuid not null references public.customer_accounts (id) on delete cascade,
  device_id          text not null check (char_length(device_id) between 8 and 128),
  refresh_token_hash text not null unique,
  expires_at         timestamptz not null,
  revoked_at         timestamptz,
  last_used_at       timestamptz not null default now(),
  created_at         timestamptz not null default now()
);

create index customer_sessions_account_idx on public.customer_sessions (account_id);

-- Convites -----------------------------------------------------------------------------

create table public.customer_portal_invites (
  id          uuid primary key default gen_random_uuid(),
  merchant_id uuid not null references public.merchants (id) on delete cascade,
  customer_id uuid not null,
  -- Telefone do cadastro no momento do envio: se o comerciante trocar o número, o convite morre
  phone       text not null,
  token_hash  text not null unique,
  expires_at  timestamptz not null,
  used_at     timestamptz,
  created_at  timestamptz not null default now(),
  constraint customer_portal_invites_customer_fkey foreign key (customer_id, merchant_id)
    references public.customers (id, merchant_id) on delete cascade
);

-- Atende as duas chaves estrangeiras: sem ele, excluir um cliente (ou um comércio) varreria todos os convites
-- da plataforma. Não é parcial em used_at porque a checagem da chave não sabe filtrar por ele
create index customer_portal_invites_merchant_customer_idx on public.customer_portal_invites (merchant_id, customer_id);

alter table public.customer_accounts enable row level security;
alter table public.customer_sessions enable row level security;
alter table public.customer_portal_invites enable row level security;

-- Funções ------------------------------------------------------------------------------

-- Mesmo esquema do comerciante (register_failed_pin_attempt): incremento atômico e bloqueio
create or replace function public.register_failed_portal_pin_attempt(
  p_account_id uuid,
  p_max_attempts integer,
  p_lock_minutes integer
)
returns timestamptz
language plpgsql
security definer
set search_path = public
as $$
declare
  v_locked_until timestamptz;
begin
  update public.customer_accounts
     set failed_pin_attempts = case
           when failed_pin_attempts + 1 >= p_max_attempts then 0
           else failed_pin_attempts + 1
         end,
         pin_locked_until = case
           when failed_pin_attempts + 1 >= p_max_attempts then now() + make_interval(mins => p_lock_minutes)
           else pin_locked_until
         end
   where id = p_account_id
  returning pin_locked_until into v_locked_until;

  return v_locked_until;
end;
$$;

-- Usa o convite e liga a loja à conta, tudo na mesma transação. p_new_pin_hash nulo: quem chamou já
-- conferiu o PIN atual da conta. Com PIN novo: cria a conta ou redefine o PIN, e nesse caso desliga as
-- outras lojas e encerra as sessões. Devolve o id da conta.
create or replace function public.redeem_customer_portal_invite(p_token_hash text, p_new_pin_hash text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invite record;
  v_account_id uuid;
begin
  -- for update: dois aceites simultâneos do mesmo link não podem passar os dois
  select i.id, i.customer_id, i.merchant_id, i.phone
    into v_invite
    from public.customer_portal_invites as i
    join public.customers as c on c.id = i.customer_id and c.merchant_id = i.merchant_id and c.phone = i.phone
   where i.token_hash = p_token_hash
     and i.used_at is null
     and i.expires_at > now()
     for update of i;

  if not found then
    raise exception 'convite inválido' using errcode = 'VQ009';
  end if;

  select a.id into v_account_id from public.customer_accounts as a where a.phone = v_invite.phone for update;

  if v_account_id is null then
    if p_new_pin_hash is null then
      raise exception 'conta inexistente' using errcode = 'VQ010';
    end if;
    insert into public.customer_accounts (phone, pin_hash) values (v_invite.phone, p_new_pin_hash)
    returning id into v_account_id;
  elsif p_new_pin_hash is not null then
    update public.customer_accounts
       set pin_hash = p_new_pin_hash, failed_pin_attempts = 0, pin_locked_until = null
     where id = v_account_id;
    update public.customers set portal_account_id = null
     where portal_account_id = v_account_id and id <> v_invite.customer_id;
    update public.customer_sessions set revoked_at = now()
     where account_id = v_account_id and revoked_at is null;
  end if;

  update public.customers set portal_account_id = v_account_id where id = v_invite.customer_id;
  update public.customer_portal_invites set used_at = now() where id = v_invite.id;

  return v_account_id;
end;
$$;

-- Convite ainda válido, para a tela do link: nome da loja, telefone do cadastro e se já há conta
create or replace function public.customer_portal_invite_info(p_token_hash text)
returns table (merchant_name text, phone text, has_account boolean)
language sql
stable
security definer
set search_path = public
as $$
  select m.name, i.phone, exists (select 1 from public.customer_accounts as a where a.phone = i.phone)
    from public.customer_portal_invites as i
    join public.customers as c on c.id = i.customer_id and c.merchant_id = i.merchant_id and c.phone = i.phone
    join public.merchants as m on m.id = i.merchant_id
   where i.token_hash = p_token_hash
     and i.used_at is null
     and i.expires_at > now();
$$;

-- Lojas ligadas à conta, com o saldo do fiado em cada uma, por nome da loja
create or replace function public.customer_portal_stores(p_account_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'customer_id', c.id,
    'merchant_name', m.name,
    'customer_name', c.name,
    'balance_cents', c.balance_cents,
    'credit_due_date', c.credit_due_date
  ) order by m.name, c.id), '[]'::jsonb)
    from public.customers as c
    join public.merchants as m on m.id = c.merchant_id
   where c.portal_account_id = p_account_id;
$$;

revoke execute on function public.register_failed_portal_pin_attempt(uuid, integer, integer) from public, anon, authenticated;
revoke execute on function public.redeem_customer_portal_invite(text, text) from public, anon, authenticated;
revoke execute on function public.customer_portal_stores(uuid) from public, anon, authenticated;
revoke execute on function public.customer_portal_invite_info(text) from public, anon, authenticated;

grant execute on function public.register_failed_portal_pin_attempt(uuid, integer, integer) to service_role;
grant execute on function public.redeem_customer_portal_invite(text, text) to service_role;
grant execute on function public.customer_portal_stores(uuid) to service_role;
grant execute on function public.customer_portal_invite_info(text) to service_role;
