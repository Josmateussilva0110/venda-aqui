import 'package:dio/dio.dart';

/// Flags lidas pelos interceptors em `RequestOptions.extra`.
abstract final class ApiRequestFlags {
  /// Rota pública (login, cadastro, recuperação): não manda token nem tenta renovar a sessão.
  static const skipAuth = 'api.skipAuth';
}

Dio? _api;

/// Cliente da API configurado na subida do app (URL, timeouts e interceptor de sessão).
/// Só [requestData] deve usá-lo.
Dio get api {
  final client = _api;
  if (client == null) throw StateError('API não configurada: chame configureApi() na inicialização.');
  return client;
}

void configureApi(Dio client) => _api = client;
