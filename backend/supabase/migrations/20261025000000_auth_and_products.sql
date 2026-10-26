-- Iteração 1: autenticação por telefone + PIN (RF01) e cadastro de produtos (RF05)

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Comerciantes ----------------------------------------------------------------

create table public.merchants (
  id                  uuid primary key default gen_random_uuid(),
  name                text not null check (char_length(name) between 2 and 80),
  phone               text not null unique check (phone ~ '^\+55[0-9]{10,11}$'),
  pin_hash            text not null,
  failed_pin_attempts integer not null default 0 check (failed_pin_attempts >= 0),
  pin_locked_until    timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create trigger merchants_set_updated_at
before update on public.merchants
for each row execute function public.set_updated_at();

-- Incremento atômico: duas tentativas simultâneas não podem ler o mesmo contador
-- e escapar do bloqueio. Devolve o momento até quando o PIN fica bloqueado, se bloqueou.
create or replace function public.register_failed_pin_attempt(
  p_merchant_id uuid,
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
  update public.merchants
     set failed_pin_attempts = case
           when failed_pin_attempts + 1 >= p_max_attempts then 0
           else failed_pin_attempts + 1
         end,
         pin_locked_until = case
           when failed_pin_attempts + 1 >= p_max_attempts then now() + make_interval(mins => p_lock_minutes)
           else pin_locked_until
         end
   where id = p_merchant_id
  returning pin_locked_until into v_locked_until;

  return v_locked_until;
end;
$$;

-- Sessões (uma por aparelho) ---------------------------------------------------

create table public.sessions (
  id                 uuid primary key default gen_random_uuid(),
  merchant_id        uuid not null references public.merchants (id) on delete cascade,
  device_id          text not null check (char_length(device_id) between 8 and 128),
  refresh_token_hash text not null unique,
  expires_at         timestamptz not null,
  revoked_at         timestamptz,
  last_used_at       timestamptz not null default now(),
  created_at         timestamptz not null default now()
);

create index sessions_merchant_id_idx on public.sessions (merchant_id);

-- Códigos de recuperação de PIN via WhatsApp ----------------------------------

create table public.pin_recovery_codes (
  id          uuid primary key default gen_random_uuid(),
  merchant_id uuid not null references public.merchants (id) on delete cascade,
  code_hash   text not null,
  attempts    integer not null default 0 check (attempts >= 0),
  expires_at  timestamptz not null,
  used_at     timestamptz,
  created_at  timestamptz not null default now()
);

create index pin_recovery_codes_merchant_id_idx on public.pin_recovery_codes (merchant_id, created_at desc);

-- Gasta uma tentativa antes de comparar o código, numa única instrução: pedidos
-- paralelos não conseguem testar vários palpites gastando uma tentativa só
create or replace function public.consume_pin_recovery_attempt(
  p_merchant_id uuid,
  p_max_attempts integer
)
returns table (id uuid, code_hash text)
language sql
security definer
set search_path = public
as $$
  update public.pin_recovery_codes as c
     set attempts = c.attempts + 1
   where c.id = (
           select p.id
             from public.pin_recovery_codes as p
            where p.merchant_id = p_merchant_id
              and p.used_at is null
              and p.expires_at > now()
            order by p.created_at desc
            limit 1
              for update
         )
     and c.attempts < p_max_attempts
  returning c.id, c.code_hash;
$$;

-- Produtos ---------------------------------------------------------------------

create table public.products (
  id               uuid primary key default gen_random_uuid(),
  merchant_id      uuid not null references public.merchants (id) on delete cascade,
  name             text not null check (char_length(name) between 1 and 80),
  photo_path       text,
  sale_price_cents integer not null check (sale_price_cents >= 0),
  cost_price_cents integer not null check (cost_price_cents >= 0),
  -- numeric para aceitar peso (kg) com até 3 casas; produtos por unidade guardam inteiros
  quantity         numeric(12, 3) not null default 0 check (quantity >= 0),
  sold_by_weight   boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  constraint products_unit_quantity_is_integer check (sold_by_weight or quantity = trunc(quantity))
);

-- Nome único por comerciante, sem diferenciar maiúsculas: evita "Tomate" e "tomate" no mesmo estoque
create unique index products_merchant_name_key on public.products (merchant_id, lower(name));

create trigger products_set_updated_at
before update on public.products
for each row execute function public.set_updated_at();

-- Acesso ------------------------------------------------------------------------
-- Só a API (chave secreta) acessa estas tabelas. RLS ligado sem políticas bloqueia
-- qualquer leitura com a chave pública, caso ela vaze para um cliente.

alter table public.merchants enable row level security;
alter table public.sessions enable row level security;
alter table public.pin_recovery_codes enable row level security;
alter table public.products enable row level security;

revoke execute on function public.register_failed_pin_attempt(uuid, integer, integer) from public, anon, authenticated;
revoke execute on function public.consume_pin_recovery_attempt(uuid, integer) from public, anon, authenticated;
grant execute on function public.register_failed_pin_attempt(uuid, integer, integer) to service_role;
grant execute on function public.consume_pin_recovery_attempt(uuid, integer) to service_role;

-- Fotos dos produtos ------------------------------------------------------------
-- Bucket público para leitura (foto de produto não é dado sensível); o upload só
-- acontece por URL assinada gerada pela API, no caminho <merchant_id>/<product_id>/.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('product-photos', 'product-photos', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;
