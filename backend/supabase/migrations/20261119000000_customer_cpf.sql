-- CPF do cliente, opcional. Guardado só com os 11 dígitos (a formatação é da tela); os dígitos
-- verificadores são conferidos na API. Único por comércio: o mesmo CPF em dois clientes é cadastro repetido.

alter table public.customers
  add column cpf text,
  add constraint customers_cpf_format check (cpf ~ '^[0-9]{11}$');

create unique index customers_merchant_cpf_key on public.customers (merchant_id, cpf) where cpf is not null;
