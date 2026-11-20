# Vendaqui — escolhas do projeto

- Código da API em `backend/`; migrations em `backend/supabase/migrations/`. O `.env` fica na raiz do
  repositório e é carregado por caminho relativo a `backend/src/config/env.ts`.
- Banco: Supabase (Postgres + Storage), acessado com `@supabase/supabase-js` em `backend/src/config/supabase.ts`.
- Autenticação própria (telefone + PIN, JWT HS256 de 15 min + refresh token opaco rotativo por aparelho).
  Não há usuário do Supabase Auth, então o único cliente é o da chave secreta, que ignora o RLS.
  **Todo acesso a dado de comerciante filtra por `merchant_id` vindo de `requireAuthField(request, "merchantId")`**
  (`AuthField` = `"merchantId" | "sessionId"`, em `backend/src/utils/requireAuthField.ts`); o RLS fica
  ligado sem políticas, só para bloquear a chave pública.
- Códigos de erro e mapas separados por domínio (`types/<domínio>/errors.ts` + `errors/<domínio>.ts`);
  `sendFailure` sempre inclui o `code` no corpo.
- Dinheiro em centavos inteiros; `quantity` é `numeric(12,3)` (produto por peso) e chega como number.
- Express 5: `request.query` é só getter; o middleware `validate` redefine a propriedade com os dados convertidos.
- Contadores disputados (tentativas de PIN, tentativas de código de recuperação) são atualizados por função SQL
  atômica (`register_failed_pin_attempt`, `consume_pin_recovery_attempt`), nunca por ler e depois gravar.
- Models existem para merchants, sessions e pin_recovery_codes (usados por mais de um service). Produtos
  falam direto com o banco no `ProductService`; vale extrair um `ProductModel` quando vendas (Iteração 2)
  precisarem das mesmas consultas.
- Vendas e fiado (`20261031010000_sales_and_credit.sql`): tudo que mexe em estoque ou saldo do cliente passa por
  função SQL (`register_sale`, `update_sale`, `register_customer_payment`), que calcula o total pelo preço do
  produto e trava os produtos em ordem de id (evita deadlock). O app nunca envia preço nem total.
  Erros de regra saem com SQLSTATE próprio `VQ001`–`VQ006` (lista em `constants/sales.ts`, `SALE_DB_ERRORS`) e o
  service traduz para o código de erro; não são `console.error`.
- `customers.balance_cents` é o saldo do fiado, guardado na linha e alterado só por essas funções.
  Venda e pagamento referenciam o cliente por chave composta `(id, merchant_id)`, com `on delete restrict`.
- `GET /customers` devolve `summary: { owingCount, owedCents }` (função `customer_credit_summary`, migration
  `20261031020000_customer_credit_summary.sql`) só quando `offset = 0`; o resumo não muda entre as páginas.
- Relatórios (`20261104000000_sale_item_cost_and_reports.sql`): `sale_items.unit_cost_cents` guarda o custo da época,
  como o preço; a edição mantém preço e custo dos itens que continuam (mapa `{price, cost}` em `_sale_apply_items`).
  `GET /reports/sales?from&to` chama `sales_report` (lucro = total vendido − custo; ranking pelo lucro, até 6).
  Regras de período compartilhadas com o histórico em `schemas/fields/period.ts`.
- Vencimento do fiado e lembretes (`20261111000000_credit_due_dates_and_reminders.sql`): um vencimento por cliente
  (`customers.credit_due_date`), mantido pelo trigger `customers_track_due_date` quando o saldo sai do zero ou zera
  (constraint: deve ⇔ tem vencimento). "Hoje" é `_local_today()` (horário de Brasília), nunca a data do app.
  Configuração em colunas de `merchants` (`GET/PUT /settings/credit`). `PUT /customers/:id/due-date` chama
  `set_customer_due_date` (VQ007 não deve, VQ008 data fora de hoje..+365). `GET /customers/reminders` (rota antes de
  `/:id`) lista os pendentes; `POST /customers/:id/reminders` grava `last_reminded_on`. O resumo do fiado traz
  `reminders: { dueCount, nextOn, hour } | null`, que o app usa para agendar o aviso local. O envio ao cliente é
  sempre pelo WhatsApp do comerciante (link wa.me); a API nunca manda mensagem.
- Conta em aberto (`GET /customers/:id/open-account`, função `customer_open_account`, migrations `20261112000000` e
  `20261113000000`): compras fiado desde a última vez que o saldo zerou (janela sobre vendas + pagamentos, sem coluna
  nova), até `OPEN_ACCOUNT_PURCHASE_LIMIT` compras com itens (`subtotal_cents` gravado na venda) e o já pago no período;
  compras listadas + anteriores − pago = saldo. Migration já aplicada não se edita: mudança de função vai em arquivo novo.
- Vendas feitas sem internet (`20261116000000_offline_sales.sql`): `POST /sales` (`CreateSaleSchema`) aceita `clientId`
  (UUID do aparelho, índice único parcial `(merchant_id, client_id)`) e `soldAt` (hora do balcão, exige `clientId`, até
  `MAX_OFFLINE_SALE_AGE_DAYS`). Reenvio com o mesmo `clientId` devolve a venda gravada com `replayed: true`, sem mexer de
  novo em estoque e saldo. Com `soldAt`, falta de estoque é aceita: o estoque para em zero (constraint `quantity >= 0`) e
  a resposta traz `stockShortfalls`. Online (sem `soldAt`) continua o 409. `created_at = least(soldAt, now())`.
  `_sale_apply_items` ganhou `p_allow_shortfall default false`; a edição (`SaleSchema`) descarta os campos offline.
- Pagamento de fiado e reposição feitos sem internet (`20261117000000_offline_payments_restocks.sql`): `POST
  /customers/:id/payments` aceita `clientId` + `paidAt` (vira `created_at`, limitado a agora) e `POST
  /products/:id/restock` aceita `clientId` (registro em `product_restocks`, que também é o histórico de entradas).
  Campos compartilhados em `schemas/fields/offline.ts`. Nas duas funções o registro com `client_id` entra ANTES do
  efeito (saldo/estoque), para o reenvio simultâneo parar no índice único sem aplicar duas vezes. Pagamento maior
  que a dívida continua VQ006 também offline (o app mostra como recusado).
- CPF do cliente (`20261119000000_customer_cpf.sql`): opcional, só os 11 dígitos (check), único por comércio
  (`customers_merchant_cpf_key`; erro `CUSTOMER_CPF_TAKEN`, 409, identificado pelo nome do índice com
  `isUniqueViolationOf`). Dígitos verificadores conferidos em `schemas/fields/cpf.ts`. No PUT, `cpf` ausente não mexe
  (app antigo não apaga), `""`/`null` apaga. Vai só no detalhe (`CUSTOMER_DETAIL_COLUMNS`), nunca nas listas.
- Portal do cliente (`20261120000000_customer_portal.sql`, rotas em `/api/portal`, domínio `portal`): o cliente final
  consulta compras e pagamentos agrupados por loja. Conta = telefone + PIN próprio (`customer_accounts`), sessões em
  `customer_sessions`, token com emissor `vendaqui-portal` (o do comerciante é `vendaqui-api`; mesmo segredo, então o
  emissor é o que impede um token de valer nas rotas do outro). Campos do request: `portalAccountId`/`portalSessionId`,
  lidos com `requireAuthField`. Uma loja só aparece quando ela envia o convite (`POST /customers/:id/portal-invite`,
  link de uso único de 24 h, só o hash no banco, mandado pelo WhatsApp do comerciante via wa.me) e o cliente aceita:
  `customers.portal_account_id`. **O CPF serve para entrar, nunca liga lojas** (é digitado pelo comerciante); CPF que
  aponta para mais de uma conta é recusado no login. Como o comerciante vê o link, aceitar convite de conta existente
  exige o PIN atual; criar PIN novo pelo convite desliga as outras lojas e revoga as sessões (tudo em
  `redeem_customer_portal_invite`, VQ009 convite inválido, VQ010 conta inexistente sem PIN novo). Trocar o telefone do
  cliente desliga a loja (trigger) e mata convites pendentes. O app do cliente é só Android (sem CORS): o link é
  `CUSTOMER_INVITE_BASE_URL?token=...` e o cliente cola no app; com domínio fixo, trocar a base por https para App Links.
  O extrato reaproveita `customer_statement`, com o `merchant_id` lido da linha ligada à conta, nunca da requisição.
