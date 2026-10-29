# Vendaqui

Gestão de vendas e estoque para o pequeno comerciante. Monorepo:

| Pasta | O que é |
|---|---|
| [`backend/`](backend/README.md) | API REST (Node + TypeScript + Express + Supabase) |
| [`frontend/`](frontend/README.md) | App Flutter (Android) |

O `.env` da API fica na raiz do repositório (`cp .env.example .env`). A configuração do app fica em
`frontend/config/api.json` (`cp frontend/config/api.example.json frontend/config/api.json`): é o único lugar
com o endereço da API, local ou de produção.

## Rodando a API

```bash
cp .env.example .env          # só na primeira vez; preencha Supabase, JWT_SECRET e PORT
cd backend
npm install                   # só na primeira vez
npm run dev
```

A API sobe em `http://localhost:<PORT>/api` (a `PORT` do `.env`). Para conferir: `curl http://localhost:<PORT>/api/health`.

## Gerando o APK

```bash
cp frontend/config/api.example.json frontend/config/api.json   # só na primeira vez; ajuste API_BASE_URL
cd frontend
flutter pub get
flutter build apk --release --split-per-abi --target-platform android-arm64 --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/api.json
```

O APK sai em `frontend/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.

- Com a API na sua máquina, `API_BASE_URL` é o IP dela na rede (`hostname -I`) com a `PORT` do `.env`, ex.:
  `http://192.168.1.15:8080/api`. O celular precisa estar no mesmo Wi-Fi.
- Com a API hospedada, troque pela URL HTTPS (ex.: `https://api.seudominio.com.br/api`) e gere o APK de novo.
- Guarde `frontend/build/symbols/` de cada versão: é o que permite ler os relatórios de erro do app ofuscado.
