-- Clientes do comerciante: quem compra fiado. Cada comerciante tem a própria lista;
-- um cliente nunca aparece para outro comércio.

create table public.customers (
  id          uuid primary key default gen_random_uuid(),
  merchant_id uuid not null references public.merchants (id) on delete cascade,
  name        text not null check (char_length(name) between 2 and 80),
  -- Mesmo formato dos comerciantes: +55 DDD número, celular sempre com o 9
  phone       text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint customers_phone_format check (phone ~ '^\+55[0-9]{10,11}$'),
  constraint customers_phone_mobile_has_nine check (phone !~ '^\+55[0-9]{2}[6-9][0-9]{7}$')
);

-- Um telefone por cliente dentro do comércio: cadastrar de novo o mesmo número é recusado
-- (a API responde com o cliente que já existe). Comércios diferentes podem ter o mesmo cliente.
create unique index customers_merchant_phone_key on public.customers (merchant_id, phone);

-- A lista de clientes ordena e busca por nome dentro do comerciante
create index customers_merchant_name_idx on public.customers (merchant_id, name);

create trigger customers_set_updated_at
before update on public.customers
for each row execute function public.set_updated_at();

-- Só a API (chave secreta) acessa: RLS ligado sem políticas bloqueia a chave pública
alter table public.customers enable row level security;
