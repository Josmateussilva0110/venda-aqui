# Vendaqui

Gestão de vendas e estoque para o pequeno comerciante. Monorepo:

| Pasta | O que é |
|---|---|
| [`backend/`](backend/README.md) | API REST (Node + TypeScript + Express + Supabase) |
| [`frontend/`](frontend/README.md) | App Flutter (Android, iOS e web) |

O `.env` da API fica na raiz do repositório (`cp .env.example .env`). A configuração do app fica em
`frontend/config/` (`cp frontend/config/dev.example.json frontend/config/dev.json`).
