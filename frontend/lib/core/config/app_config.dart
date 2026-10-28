import 'package:flutter/foundation.dart' show immutable;

/// Configuração de ambiente vinda de `--dart-define-from-file=config/api.json`.
/// É o único lugar com o endereço da API: para ir do servidor local para o de produção, troque a URL lá.
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
      throw StateError('API_BASE_URL ausente. Rode com --dart-define-from-file=config/api.json.');
    }
    return AppConfig(
      apiBaseUrl: parseApiUrl(rawUrl),
      httpTimeout: Duration(seconds: int.tryParse(rawTimeout) ?? _defaultTimeoutSeconds),
    );
  }

  /// HTTP só é aceito para endereços da rede local (servidor rodando na máquina de desenvolvimento).
  /// Qualquer endereço público precisa de HTTPS, inclusive no build de release.
  static Uri parseApiUrl(String raw) {
    final url = Uri.tryParse(raw.trim());
    if (url == null || !url.hasAuthority || (url.scheme != 'https' && url.scheme != 'http')) {
      throw StateError('API_BASE_URL inválida: use http(s)://host[:porta]/api.');
    }
    if (url.scheme == 'http' && !isLocalNetworkHost(url.host)) {
      throw StateError('API_BASE_URL pública precisa usar HTTPS.');
    }
    return url;
  }

  static bool isLocalNetworkHost(String host) {
    if (host == 'localhost' || host.endsWith('.local')) return true;
    final octets = host.split('.').map(int.tryParse).toList();
    if (octets.length != 4 || octets.any((octet) => octet == null || octet < 0 || octet > 255)) return false;
    final [first, second, ..._] = octets.cast<int>();
    return first == 127 || first == 10 || (first == 192 && second == 168) || (first == 172 && second >= 16 && second <= 31);
  }
}
