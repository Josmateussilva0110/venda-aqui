# Vendaqui — escolhas do projeto

- Código da API em `backend/`; migrations em `backend/supabase/migrations/`. O `.env` fica na raiz do
  repositório e é carregado por caminho relativo a `backend/src/config/env.ts`.
- Banco: Supabase (Postgres + Storage), acessado com `@supabase/supabase-js` em `backend/src/config/supabase.ts`.
- Autenticação própria (telefone + PIN, JWT HS256 de 15 min + refresh token opaco rotativo por aparelho).
  Não há usuário do Supabase Auth, então o único cliente é o da chave secreta, que ignora o RLS.
  **Todo acesso a dado de comerciante filtra por `merchant_id` vindo de `request.merchantId`**; o RLS fica
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
