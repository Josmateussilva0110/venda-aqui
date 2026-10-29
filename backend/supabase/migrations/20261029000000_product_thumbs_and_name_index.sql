-- Miniatura da foto do produto: o app gera (~256 px) e envia junto com a foto.
-- Listas usam a miniatura; a foto inteira só aparece na edição. Fotos antigas ficam sem
-- miniatura (null) e o app cai para a foto inteira até ela ser trocada.
alter table public.products add column if not exists thumb_path text;

-- A listagem ordena por nome dentro do comerciante; o índice único é sobre lower(name)
-- e não serve para "order by name", que sem este índice ordena todos os produtos da conta
create index if not exists products_merchant_name_idx on public.products (merchant_id, name);
