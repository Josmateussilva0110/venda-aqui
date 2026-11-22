# Vendaqui Cliente — app Flutter (Android)

App do **cliente final**: ele consulta as compras fiado e os pagamentos que fez em cada loja que usa o Vendaqui,
agrupados por loja. Fala só com as rotas `/api/portal` do backend.

## Como o cliente ganha acesso

1. No app do comerciante, a loja gera um **link de acesso** para o cliente e manda pelo WhatsApp dela
   (`POST /customers/:id/portal-invite`; o link vale 24 h e só uma vez).
2. O cliente copia a mensagem no WhatsApp e, no app, toca em **"Tenho um link de acesso"** e cola.
   Tocar no link não abre o app: para isso seria preciso App Links, que exigem a API num domínio HTTPS fixo
   (`CUSTOMER_INVITE_BASE_URL` no `.env` define como o link começa).
3. Na primeira vez ele **cria um PIN**; depois entra quando quiser com **telefone ou CPF + PIN**.
4. Outra loja só aparece quando ela também manda um link (botão de link na tela "Minhas lojas"). Com acesso já
   criado, o link pede o PIN atual; "esqueci o PIN" cria um novo, mas aí as outras lojas saem da consulta até mandarem
   um link novo (o comerciante vê o link, então um link não pode abrir as compras feitas em outras lojas).

## Rodando

O endereço da API fica em `config/api.json` (fora do git; copie de `config/api.example.json`), no mesmo formato do
app do comerciante. HTTP só é aceito para endereços da rede local; endereço público exige HTTPS.

```bash
cp config/api.example.json config/api.json   # só na primeira vez; ajuste API_BASE_URL (IP da máquina na rede)
flutter pub get
flutter run --dart-define-from-file=config/api.json
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/api.json
```

A sessão fica no Keystore (`flutter_secure_storage`): o cliente continua logado por 30 dias.

## Código

Mesma arquitetura do app do comerciante (Feature-First, `requestData` como única porta para a API, tema central).
O núcleo (`lib/core/`: rede, tema, widgets básicos) foi copiado de `frontend/lib/core/`; ao corrigir algo ali,
confira se vale também no outro app.
