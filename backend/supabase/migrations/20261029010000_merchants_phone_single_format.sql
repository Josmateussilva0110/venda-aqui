-- Um celular só tem uma forma salva: sempre com o 9 (+55 DDD 9XXXXXXXX). A API já completa o 9
-- quando o número chega no formato antigo; esta trava garante o mesmo no banco, para a unique de
-- phone não deixar passar a mesma linha cadastrada com e sem o 9. Fixos (começam de 2 a 5) seguem aceitos.
alter table public.merchants
  add constraint merchants_phone_mobile_has_nine
  check (phone !~ '^\+55[0-9]{2}[6-9][0-9]{7}$');
