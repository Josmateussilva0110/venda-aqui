# Vendaqui — app Flutter

App do comerciante (Iteração 1): boas-vindas, login por telefone + PIN, cadastro, recuperação de PIN pelo
WhatsApp, início com resumo do estoque, lista de estoque (busca, filtros e paginação no servidor), cadastro e
edição de produto com foto, e reposição de estoque. Telas baseadas no protótipo *Vendaqui Protótipo v4*.

## Rodando

1. Suba a API (`../backend`, veja o README de lá).
2. `cp config/dev.example.json config/dev.json` e ajuste `API_BASE_URL`
   (emulador Android: `http://10.0.2.2:3333/api`; iOS/web: `http://localhost:3333/api`).
3. `flutter run --dart-define-from-file=config/dev.json`

Release: `flutter build apk --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/prod.json`
(a URL de produção precisa ser HTTPS; o app não sobe com HTTP em release).

A foto da tela de boas-vindas não está no repositório. Coloque-a em `assets/images/welcome_merchant.jpg`
(protótipo: foto de Adolfo Florêncio / Pexels). Sem o arquivo, a tela mostra a folha da marca.

| Comando | O que faz |
|---|---|
| `flutter analyze` | lints (sem avisos) |
| `dart format lib test` | formatação (largura 140) |
| `flutter test` | conversão de dinheiro, renovação/encerramento de sessão e layout das telas em 4 tamanhos × 2 escalas de fonte |
| `flutter gen-l10n` | regenera os textos a partir de `lib/l10n/app_pt.arb` |

## Estrutura

```
lib/
  app/        MaterialApp, rotas (go_router), shell de navegação, injeção de dependências
  core/       tema (tokens via ThemeExtension), config, rede (Dio + envelope da API), sessão segura, widgets comuns
  features/
    auth/       boas-vindas, login, cadastro, recuperar PIN, estado de sessão
    dashboard/  início
    products/   estoque, formulário único de produto (create/edit), reposição
  l10n/       textos (pt-BR)
```

## Decisões

- **Sessão**: access token (15 min) só em memória; refresh token e id do aparelho no Keychain/Keystore
  (`flutter_secure_storage`). O interceptor renova uma vez quando a API responde `ACCESS_TOKEN_INVALID` e
  limpa tudo em `SESSION_*`. Sem rede na renovação, mantém o login e mostra erro de conexão.
- **Nada de regra de negócio no app**: situação do estoque (normal/baixo/esgotado), limite de "baixo", contagens
  e o novo total da reposição vêm do servidor. A margem no formulário e a prévia do total são só orientação.
- **Acesso ao backend**: só pela função `requestData` (`lib/core/network/request_data.dart`), que nunca lança e devolve
  `ApiResponse<T>`; os data sources convertem em falha de domínio com `requireData()`/`ensureSuccess()`.
- **Foto**: o app pede uma URL assinada à API e envia o arquivo direto ao Storage com um cliente HTTP
  separado, que não carrega o token da API.
