import 'package:dio/dio.dart';

import '../network/api_codes.dart';
import '../network/api_response.dart';
import '../network/auth_interceptor.dart';
import '../network/json_reader.dart';
import '../network/request_data.dart';
import 'token_store.dart';

typedef _Tokens = ({String accessToken, String refreshToken});

/// Renova a sessão com o refresh token guardado. Passa um cliente sem interceptor para
/// [requestData], senão a renovação esperaria na fila do próprio interceptor.
/// Cada refresh token só vale uma vez: o novo é salvo antes de qualquer outra requisição.
class SessionRefresher {
  SessionRefresher({required Dio plainClient, required this._tokenStore}) : _client = plainClient;

  final Dio _client;
  final TokenStore _tokenStore;

  Future<RefreshOutcome> refresh() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null) return RefreshOutcome.sessionEnded;

    final response = await requestData<_Tokens>(
      endpoint: ApiPaths.refresh,
      method: 'POST',
      data: {'refreshToken': refreshToken, 'deviceId': await _tokenStore.deviceId()},
      withAuth: false,
      client: _client,
      parse: (json) {
        final data = json! as Map<String, dynamic>;
        return (accessToken: data.requireString('accessToken'), refreshToken: data.requireString('refreshToken'));
      },
    );

    final tokens = response.data;
    if (response.success && tokens != null) {
      await _tokenStore.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
      return RefreshOutcome.renewed;
    }
    // 401 ou 422 significam token recusado; o resto (rede, 5xx) pode ser passageiro
    final status = response.error?.status;
    final rejected = response.error?.reason == ApiErrorReason.serverError && (status == 401 || status == 422);
    return rejected ? RefreshOutcome.sessionEnded : RefreshOutcome.unreachable;
  }
}
