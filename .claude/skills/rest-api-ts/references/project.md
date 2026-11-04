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
