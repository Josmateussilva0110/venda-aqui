import 'package:dio/dio.dart';

import '../security/token_store.dart';
import 'api_client.dart';
import 'api_codes.dart';
import 'app_failure.dart';

enum RefreshOutcome { renewed, sessionEnded, unreachable }

typedef RefreshSession = Future<RefreshOutcome> Function();

/// Coloca o access token nas requisições e, quando ele vence, renova a sessão uma vez e repete.
/// Se a sessão acabou de vez, avisa [onSessionEnded] para o app voltar ao login.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this._tokenStore, required this._retryClient, required this.refreshSession, required this.onSessionEnded});

  final TokenStore _tokenStore;
  final Dio _retryClient;
  final RefreshSession refreshSession;
  final void Function() onSessionEnded;

  static const _retriedFlag = 'auth.retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenStore.accessToken;
    if (token != null && !_skipsAuth(options)) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final error = err;
    // Rotas públicas (login, cadastro…) respondem 401 por PIN errado, não por sessão
    if (_skipsAuth(error.requestOptions)) return handler.next(error);
    final code = _codeOf(error.response);
    final isUnauthorized = error.response?.statusCode == 401;

    if (isUnauthorized && ApiCodes.sessionEndingCodes.contains(code)) {
      await _endSession();
      return handler.reject(_withFailure(error, const SessionExpiredFailure()));
    }

    final canRetry = isUnauthorized && code == ApiCodes.accessTokenInvalid && error.requestOptions.extra[_retriedFlag] != true;
    if (!canRetry) return handler.next(error);

    // Com QueuedInterceptor, pedidos que falharam juntos esperam aqui; só o primeiro renova de verdade
    final sentToken = _bearerOf(error.requestOptions);
    final alreadyRenewed = _tokenStore.accessToken != null && _tokenStore.accessToken != sentToken;
    final outcome = alreadyRenewed ? RefreshOutcome.renewed : await refreshSession();
    if (outcome == RefreshOutcome.sessionEnded) {
      await _endSession();
      return handler.reject(_withFailure(error, const SessionExpiredFailure()));
    }
    // Sem rede não dá para saber se a sessão ainda vale: mantém o login e mostra erro de conexão
    if (outcome == RefreshOutcome.unreachable) {
      return handler.reject(_withFailure(error, const NetworkFailure()));
    }

    try {
      final options = error.requestOptions
        ..extra[_retriedFlag] = true
        ..headers['Authorization'] = 'Bearer ${_tokenStore.accessToken}';
      handler.resolve(await _retryClient.fetch<Object?>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<void> _endSession() async {
    await _tokenStore.clearSession();
    onSessionEnded();
  }

  static bool _skipsAuth(RequestOptions options) => options.extra[ApiRequestFlags.skipAuth] == true;

  static String? _codeOf(Response<Object?>? response) {
    final body = response?.data;
    if (body is Map<String, dynamic> && body['code'] is String) return body['code'] as String;
    return null;
  }

  static String? _bearerOf(RequestOptions options) {
    final header = options.headers['Authorization'];
    return header is String && header.startsWith('Bearer ') ? header.substring(7) : null;
  }

  static DioException _withFailure(DioException error, AppFailure failure) {
    return error.copyWith(error: failure);
  }
}
