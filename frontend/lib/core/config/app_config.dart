import 'package:flutter/foundation.dart';

/// Configuração de ambiente vinda de `--dart-define-from-file=config/<ambiente>.json`.
/// Nada aqui é segredo: tudo que vai no binário pode ser extraído.
@immutable
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.httpTimeout});

  final Uri apiBaseUrl;
  final Duration httpTimeout;

  static const _defaultTimeoutSeconds = 15;

  factory AppConfig.fromEnvironment() {
    const rawUrl = String.fromEnvironment('API_BASE_URL');
    const rawTimeout = String.fromEnvironment('HTTP_TIMEOUT_SECONDS');

    if (rawUrl.isEmpty) {
      throw StateError('API_BASE_URL ausente. Rode com --dart-define-from-file=config/dev.json.');
    }
    final url = Uri.parse(rawUrl);
    // Em release só HTTPS; HTTP fica liberado apenas para o servidor local de desenvolvimento
    if (kReleaseMode && url.scheme != 'https') {
      throw StateError('API_BASE_URL precisa usar HTTPS em release.');
    }

    return AppConfig(
      apiBaseUrl: url,
      httpTimeout: Duration(seconds: int.tryParse(rawTimeout) ?? _defaultTimeoutSeconds),
    );
  }
}
