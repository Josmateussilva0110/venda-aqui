-- Vencimento do fiado (um por cliente) e lembretes pelo WhatsApp.
-- O envio é do próprio comerciante (link wa.me no app): aqui só se decide quem lembrar e quando.
--
-- Erros de regra seguem a classe VQ das vendas:
--   VQ007 cliente não está devendo (não há vencimento para mudar)
--   VQ008 vencimento fora do intervalo aceito (antes de hoje ou mais de um ano à frente)

-- Configuração do fiado, por comerciante -----------------------------------------------

alter table public.merchants
  add column credit_term_days          smallint not null default 30 check (credit_term_days between 1 and 180),
  add column reminders_enabled         boolean  not null default true,
  -- 0 desliga o lembrete antes do vencimento
  add column remind_days_before        smallint not null default 3 check (remind_days_before between 0 and 30),
  add column remind_on_due             boolean  not null default true,
  -- 0 desliga os lembretes depois de vencido
  add column remind_overdue_every_days smallint not null default 7 check (remind_overdue_every_days between 0 and 30),
  -- Hora do aviso no aparelho do comerciante
  add column reminder_hour             smallint not null default 9 check (reminder_hour between 0 and 23);

-- "Hoje" do comércio. Todo cliente é do Brasil (+55); o horário de Brasília erra no máximo
-- algumas horas perto da meia-noite nos outros fusos, o que não muda um prazo em dias.
create or replace function public._local_today()
returns date
language sql
stable
as $$
  select (now() at time zone 'America/Sao_Paulo')::date;
$$;

-- Vencimento do cliente ---------------------------------------------------------------

alter table public.customers
  add column credit_due_date  date,
  -- Último lembrete aberto no WhatsApp; o próximo só aparece depois da próxima data de lembrete
  add column last_reminded_on date;

-- Quem já devia antes desta migration ganha o prazo padrão a partir de hoje
update public.customers as c
   set credit_due_date = public._local_today() + m.credit_term_days
  from public.merchants as m
 where m.id = c.merchant_id and c.balance_cents > 0;

-- Quem deve sempre tem vencimento; quem está em dia nunca tem
alter table public.customers
  add constraint customers_due_date_when_owing check ((balance_cents > 0) = (credit_due_date is not null));

-- O saldo só muda pelas funções de venda e pagamento; o vencimento acompanha aqui, na mesma
-- transação, sem precisar mexer em cada uma delas. A dívida começa (saldo sai do zero): prazo
-- padrão a partir de hoje. Quitou: sem vencimento. Compra nova com dívida aberta mantém o prazo.
create or replace function public._customers_track_due_date()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.balance_cents = 0 then
    new.credit_due_date := null;
    new.last_reminded_on := null;
  elsif old.balance_cents = 0 then
    select public._local_today() + m.credit_term_days into new.credit_due_date
      from public.merchants as m
     where m.id = new.merchant_id;
    new.last_reminded_on := null;
  end if;
  return new;
end;
$$;

create trigger customers_track_due_date
before update of balance_cents on public.customers
for each row execute function public._customers_track_due_date();

-- Datas de lembrete --------------------------------------------------------------------
-- Um cliente tem lembretes em: (vencimento - dias antes), no vencimento e a cada N dias depois.

-- As três são uma expressão só, sem FROM nem agregação: assim o planejador as embute na consulta.
-- Com "select max(...) from (values ...)" elas rodavam como função à parte em cada devedor
-- (medido: resumo de 1 ms para 556 ms com 5 mil devedores). greatest/least ignoram nulos, como max/min.

-- Data de lembrete mais recente até hoje (nula se nenhuma chegou)
create or replace function public._reminder_latest(p_due date, p_today date, p_before smallint, p_on_due boolean, p_every smallint)
returns date
language sql
immutable
as $$
  select greatest(
    case when p_before > 0 and p_due - p_before <= p_today then p_due - p_before end,
    case when p_on_due and p_due <= p_today then p_due end,
    case when p_every > 0 and p_today - p_due >= p_every then p_due + ((p_today - p_due) / p_every) * p_every end
  );
$$;

-- Próxima data de lembrete depois de hoje (nula se não haverá outra)
create or replace function public._reminder_next(p_due date, p_today date, p_before smallint, p_on_due boolean, p_every smallint)
returns date
language sql
immutable
as $$
  select least(
    case when p_before > 0 and p_due - p_before > p_today then p_due - p_before end,
    case when p_on_due and p_due > p_today then p_due end,
    case when p_every > 0 then p_due + (greatest(p_today - p_due, 0) / p_every + 1) * p_every end
  );
$$;

-- Lembrete pendente: chegou uma data de lembrete e ele ainda não foi aberto desde então.
-- Não some à meia-noite: se o comerciante não abrir o app no dia, continua na lista.
create or replace function public._reminder_pending(
  p_due date, p_last_reminded date, p_today date, p_before smallint, p_on_due boolean, p_every smallint
)
returns boolean
language sql
immutable
as $$
  select public._reminder_latest(p_due, p_today, p_before, p_on_due, p_every) is not null
     and (p_last_reminded is null or p_last_reminded < public._reminder_latest(p_due, p_today, p_before, p_on_due, p_every));
$$;

-- Funções chamadas pela API ------------------------------------------------------------

-- Prolongar (ou adiantar) o vencimento. Devolve a data gravada.
create or replace function public.set_customer_due_date(p_merchant_id uuid, p_customer_id uuid, p_due_date date)
returns date
language plpgsql
security definer
set search_path = public
as $$
declare
  v_balance integer;
  v_today date := public._local_today();
begin
  select balance_cents into v_balance
    from public.customers
   where id = p_customer_id and merchant_id = p_merchant_id
     for update;

  if not found then
    raise exception 'customer_not_found' using errcode = 'VQ004';
  end if;
  if v_balance = 0 then
    raise exception 'customer_not_owing' using errcode = 'VQ007';
  end if;
  if p_due_date < v_today or p_due_date > v_today + 365 then
    raise exception 'invalid_due_date' using errcode = 'VQ008';
  end if;

  update public.customers set credit_due_date = p_due_date where id = p_customer_id;
  return p_due_date;
end;
$$;

-- Marca que o lembrete foi aberto no WhatsApp hoje. Nulo quando o cliente não existe ou não deve.
create or replace function public.mark_customer_reminded(p_merchant_id uuid, p_customer_id uuid)
returns uuid
language sql
security definer
set search_path = public
as $$
  update public.customers
     set last_reminded_on = public._local_today()
   where id = p_customer_id and merchant_id = p_merchant_id and balance_cents > 0
  returning id;
$$;

-- Clientes com lembrete pendente, do vencimento mais antigo para o mais novo.
-- reminder_kind diz qual mensagem usar: antes do vencimento, no dia ou vencido.
create or replace function public.list_credit_reminders(p_merchant_id uuid, p_limit integer, p_offset integer)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  with settings as (
    select m.reminders_enabled, m.remind_days_before, m.remind_on_due, m.remind_overdue_every_days,
           public._local_today() as today
      from public.merchants as m
     where m.id = p_merchant_id
  ),
  pending as (
    select c.id, c.name, c.phone, c.balance_cents, c.credit_due_date,
           case when c.credit_due_date > s.today then 'upcoming'
                when c.credit_due_date = s.today then 'due'
                else 'overdue' end as reminder_kind
      from public.customers as c
      cross join settings as s
     where c.merchant_id = p_merchant_id
       and c.balance_cents > 0
       and s.reminders_enabled
       and public._reminder_pending(c.credit_due_date, c.last_reminded_on, s.today,
                                    s.remind_days_before, s.remind_on_due, s.remind_overdue_every_days)
  ),
  page as (
    select * from pending order by credit_due_date, name, id limit p_limit offset p_offset
  )
  select jsonb_build_object(
    'total', (select count(*) from pending),
    'items', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', id, 'name', name, 'phone', phone, 'balance_cents', balance_cents,
        'credit_due_date', credit_due_date, 'reminder_kind', reminder_kind
      ) order by credit_due_date, name, id) from page
    ), '[]'::jsonb)
  );
$$;

-- O resumo do fiado passa a dizer quantos lembretes estão pendentes e quando vem o próximo,
-- para o app avisar o comerciante na hora configurada. Muda o retorno: precisa recriar.
drop function public.customer_credit_summary(uuid);

create function public.customer_credit_summary(p_merchant_id uuid)
returns table (
  owing_count       integer,
  owed_cents        bigint,
  reminders_enabled boolean,
  reminder_hour     smallint,
  reminders_due     integer,
  next_reminder_on  date
)
language sql
stable
security definer
set search_path = public
as $$
  with settings as (
    select m.reminders_enabled, m.reminder_hour, m.remind_days_before, m.remind_on_due, m.remind_overdue_every_days,
           public._local_today() as today
      from public.merchants as m
     where m.id = p_merchant_id
  )
  select count(c.id)::integer,
         coalesce(sum(c.balance_cents), 0)::bigint,
         s.reminders_enabled,
         s.reminder_hour,
         -- Lembretes desligados: nada pendente e nenhum aviso agendado
         (count(c.id) filter (
           where s.reminders_enabled
             and public._reminder_pending(c.credit_due_date, c.last_reminded_on, s.today,
                                          s.remind_days_before, s.remind_on_due, s.remind_overdue_every_days)
         ))::integer,
         case when s.reminders_enabled then
           min(public._reminder_next(c.credit_due_date, s.today, s.remind_days_before, s.remind_on_due, s.remind_overdue_every_days))
         end
    from settings as s
    left join public.customers as c on c.merchant_id = p_merchant_id and c.balance_cents > 0
   group by s.reminders_enabled, s.reminder_hour;
$$;

-- Acesso ------------------------------------------------------------------------------

revoke execute on function public._local_today() from public, anon, authenticated;
revoke execute on function public._customers_track_due_date() from public, anon, authenticated;
revoke execute on function public._reminder_latest(date, date, smallint, boolean, smallint) from public, anon, authenticated;
revoke execute on function public._reminder_next(date, date, smallint, boolean, smallint) from public, anon, authenticated;
revoke execute on function public._reminder_pending(date, date, date, smallint, boolean, smallint) from public, anon, authenticated;

revoke execute on function public.set_customer_due_date(uuid, uuid, date) from public, anon, authenticated;
revoke execute on function public.mark_customer_reminded(uuid, uuid) from public, anon, authenticated;
revoke execute on function public.list_credit_reminders(uuid, integer, integer) from public, anon, authenticated;
revoke execute on function public.customer_credit_summary(uuid) from public, anon, authenticated;

grant execute on function public.set_customer_due_date(uuid, uuid, date) to service_role;
grant execute on function public.mark_customer_reminded(uuid, uuid) to service_role;
grant execute on function public.list_credit_reminders(uuid, integer, integer) to service_role;
grant execute on function public.customer_credit_summary(uuid) to service_role;
