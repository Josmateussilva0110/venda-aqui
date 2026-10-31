-- A lista de clientes ordena por nome e desempata pelo id (nomes iguais não repetem nem somem
-- entre as páginas). Com o id no índice, a página sai já ordenada dele, sem ordenar em memória.
-- Troca dentro da mesma transação da migration: a tabela não fica sem índice em nenhum momento.

drop index public.customers_merchant_name_idx;

create index customers_merchant_name_idx on public.customers (merchant_id, name, id);
