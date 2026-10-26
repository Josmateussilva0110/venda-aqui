# Vendaqui API

Backend do Vendaqui, Iteração 1: autenticação por telefone + PIN (RF01) e cadastro de produtos (RF05).
Node 20+, TypeScript, Express 5, zod e Supabase (Postgres + Storage).

## Rodando

1. Crie um projeto no Supabase e aplique a migration `supabase/migrations/20261025000000_auth_and_products.sql`
   (pelo SQL Editor ou com `supabase db push`). Ela cria as tabelas, as funções e o bucket `product-photos`.
2. Na raiz do repositório (não em `backend/`), `cp .env.example .env` e preencha `SUPABASE_URL`, `SUPABASE_SECRET_KEY` e `JWT_SECRET`.
3. `npm install` e depois `npm run dev`. A API sobe em `http://localhost:3333/api`.

| Script | O que faz |
|---|---|
| `npm run dev` | servidor com reload |
| `npm run build` / `npm start` | compila para `dist/` e roda |
| `npm run typecheck` | checagem de tipos |
| `npm test` | testes de schema e do contrato HTTP (não precisam de banco) |

A API não sobe se faltar alguma variável de ambiente: ela lista o que está faltando e encerra.

## Contrato

Toda resposta usa o mesmo envelope:

```json
{ "success": true,  "message": "…", "data": { } }
{ "success": false, "message": "…", "code": "PIN_LOCKED" }
{ "success": false, "message": "Erro de validação", "errors": [{ "field": "pin", "message": "…" }] }
```

- Validação responde **422**, e `errors[].field` é o nome do campo enviado, para o app marcar o input.
- Valores em dinheiro são **centavos inteiros** (`salePriceCents: 850` = R$ 8,50).
- `quantity` aceita até 3 casas decimais só quando `soldByWeight` é `true` (kg); nos outros casos precisa ser inteira.
- Telefone pode ir como o usuário digita (`(86) 99999-0000`) e volta sempre como `+5586999990000`.

### Sessão

O login devolve `accessToken` (15 min) e `refreshToken` (90 dias, renovado a cada uso). Mande
`Authorization: Bearer <accessToken>` nas rotas protegidas. O app precisa gerar um `deviceId` estável por
instalação e enviá-lo no cadastro, no login, na renovação e na recuperação.

| `code` no 401 | O que o app faz |
|---|---|
| `ACCESS_TOKEN_INVALID` | chama `POST /auth/refresh` e repete a requisição |
| `SESSION_INVALID`, `SESSION_EXPIRED`, `SESSION_REVOKED` | apaga a sessão local e mostra a tela de login |

Cada refresh token só vale uma vez: guarde o novo que vem na resposta.

### Autenticação — `/api/auth`

| Método | Rota | Corpo | Resposta (`data`) |
|---|---|---|---|
| POST | `/phone/check` | `{ phone }` | `{ available }`, usado na etapa 1 do cadastro |
| POST | `/register` | `{ name, phone, pin, pinConfirmation, deviceId }` | sessão (201) |
| POST | `/login` | `{ phone, pin, deviceId }` | sessão |
| POST | `/refresh` | `{ refreshToken, deviceId }` | tokens novos |
| POST | `/logout` | (autenticado) | |
| GET | `/me` | (autenticado) | `{ id, name, phone, createdAt }` |
| POST | `/pin-recovery/request` | `{ phone }` | envia código de 6 dígitos pelo WhatsApp |
| POST | `/pin-recovery/confirm` | `{ phone, code, pin, pinConfirmation, deviceId }` | sessão |

Sessão = `{ merchant, accessToken, accessTokenExpiresIn, refreshToken, refreshTokenExpiresAt }`.

Regras de negócio:

- O PIN tem de 4 a 6 dígitos. No cadastro e na recuperação, PINs como `0000` e `1234` são recusados.
- Depois de 5 PINs errados a conta fica bloqueada por 15 minutos (`429 PIN_LOCKED`), mesmo que o PIN certo seja digitado.
- Entrar de novo no mesmo aparelho encerra a sessão anterior dele. Se um refresh token for usado em outro aparelho, a sessão é revogada.
- Recuperar o PIN encerra todas as sessões da conta. O código vale por 10 minutos e aceita 5 tentativas.

### Produtos — `/api/products` (todas autenticadas)

| Método | Rota | Corpo / query | Resposta (`data`) |
|---|---|---|---|
| GET | `/` | `?search=&limit=50&offset=0` | `{ items, total, limit, offset }`, ordenado por nome |
| POST | `/` | `{ name, salePriceCents, costPriceCents, quantity, soldByWeight }` | `{ id }` (201) |
| GET | `/:id` | | produto |
| PUT | `/:id` | mesmo corpo do POST | `{ id }` |
| POST | `/:id/photo/upload-url` | `{ contentType }` (`image/jpeg`, `image/png` ou `image/webp`) | `{ path, signedUrl, token }` |
| PUT | `/:id/photo` | `{ path }` | `{ id }` |

Produto = `{ id, name, photoUrl, salePriceCents, costPriceCents, quantity, soldByWeight, createdAt, updatedAt }`.
O nome é único por comerciante, sem diferenciar maiúsculas de minúsculas (`409 PRODUCT_NAME_TAKEN`).

Para enviar a foto: (1) peça a URL em `/photo/upload-url`; (2) envie o arquivo direto ao Supabase com
`supabase.storage.from("product-photos").uploadToSignedUrl(path, token, file)` ou com um `PUT` em `signedUrl`;
(3) confirme com `PUT /:id/photo`. A foto anterior é apagada do bucket. O limite é de 5 MB.

## Decisões

- **Autenticação própria, não o Supabase Auth.** O login é telefone + PIN de 4 dígitos, sem SMS. O Supabase Auth
  exige senha de pelo menos 6 caracteres e um provedor de SMS para telefone. O PIN é guardado com bcrypt; o refresh
  token e o código de recuperação, com SHA-256.
- **A API usa a chave secreta do Supabase**, que ignora o RLS, porque não existe usuário do Supabase Auth para as
  políticas avaliarem. Por isso **toda consulta filtra por `merchant_id` vindo do token**. O RLS fica ligado sem
  políticas, para que a chave pública não leia nada se vazar.
- **WhatsApp**: `WHATSAPP_PROVIDER=console` imprime o código no terminal (só em desenvolvimento; a API não sobe com
  ele em produção). `meta` usa a WhatsApp Cloud API com um template de autenticação aprovado no Meta Business.
