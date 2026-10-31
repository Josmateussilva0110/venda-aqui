import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/network/api_response.dart';
import 'package:vendaqui/core/network/app_failure.dart';
import 'package:vendaqui/core/network/auth_interceptor.dart';
import 'package:vendaqui/core/network/request_data.dart';
import 'package:vendaqui/core/security/token_store.dart';

/// Responde cada requisição com a próxima resposta da fila e registra o que foi enviado.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._responses);

  final List<(int, Map<String, Object?>)> _responses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = _responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late TokenStore tokenStore;
  late bool sessionEnded;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tokenStore = TokenStore(const FlutterSecureStorage());
    await tokenStore.saveTokens(accessToken: 'old-access', refreshToken: 'refresh-1');
    sessionEnded = false;
  });

  Dio clientWith(_ScriptedAdapter adapter, Future<RefreshOutcome> Function() refresh) {
    final retryClient = Dio()..httpClientAdapter = adapter;
    return Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokenStore: tokenStore,
          retryClient: retryClient,
          refreshSession: refresh,
          onSessionEnded: () => sessionEnded = true,
        ),
      );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProducts(Dio client) {
    return requestData<Map<String, dynamic>>(endpoint: '/products', client: client, parse: (json) => json! as Map<String, dynamic>);
  }

  test('token vencido: renova uma vez e repete a requisição com o token novo', () async {
    final adapter = _ScriptedAdapter([
      (401, {'success': false, 'message': 'Token inválido.', 'code': 'ACCESS_TOKEN_INVALID'}),
      (
        200,
        {
          'success': true,
          'message': 'ok',
          'data': {'value': 1},
        },
      ),
    ]);
    final client = clientWith(adapter, () async {
      await tokenStore.saveTokens(accessToken: 'new-access', refreshToken: 'refresh-2');
      return RefreshOutcome.renewed;
    });

    final response = await getProducts(client);

    expect(response.requireData(), {'value': 1});
    expect(adapter.requests.last.headers['Authorization'], 'Bearer new-access');
    expect(sessionEnded, isFalse);
  });

  test('sessão revogada: apaga os tokens do aparelho e avisa o app', () async {
    final adapter = _ScriptedAdapter([
      (401, {'success': false, 'message': 'Sessão encerrada.', 'code': 'SESSION_REVOKED'}),
    ]);
    final client = clientWith(adapter, () async => RefreshOutcome.renewed);

    final response = await getProducts(client);

    expect(response.success, isFalse);
    expect(response.toFailure(), isA<SessionExpiredFailure>());
    expect(sessionEnded, isTrue);
    expect(tokenStore.accessToken, isNull);
    expect(await tokenStore.readRefreshToken(), isNull);
  });

  test('sem rede na renovação: mantém a sessão e informa falha de conexão', () async {
    final adapter = _ScriptedAdapter([
      (401, {'success': false, 'message': 'Token inválido.', 'code': 'ACCESS_TOKEN_INVALID'}),
    ]);
    final client = clientWith(adapter, () async => RefreshOutcome.unreachable);

    final response = await getProducts(client);

    expect(response.toFailure(), isA<NetworkFailure>());
    expect(sessionEnded, isFalse);
    expect(await tokenStore.readRefreshToken(), 'refresh-1');
  });

  test('rota pública com 401 (PIN errado) não renova nem encerra a sessão', () async {
    final adapter = _ScriptedAdapter([
      (401, {'success': false, 'message': 'Telefone ou PIN incorretos.', 'code': 'INVALID_CREDENTIALS'}),
    ]);
    var refreshed = false;
    final client = clientWith(adapter, () async {
      refreshed = true;
      return RefreshOutcome.renewed;
    });

    final response = await requestData<void>(
      endpoint: '/auth/login',
      method: 'POST',
      data: {'pin': '0000'},
      withAuth: false,
      client: client,
    );

    expect(response.message, 'Telefone ou PIN incorretos.');
    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
    expect(refreshed, isFalse);
    expect(sessionEnded, isFalse);
  });

  test('erro de validação chega com a mensagem de cada campo, para a tela marcar o input', () async {
    final adapter = _ScriptedAdapter([
      (
        422,
        {
          'success': false,
          'message': 'Erro de validação',
          'errors': [
            {'field': 'quantity', 'message': 'Use no máximo 3 casas decimais.'},
            {'field': 'name', 'message': 'Informe o nome do produto.'},
          ],
        },
      ),
    ]);
    final client = clientWith(adapter, () async => RefreshOutcome.renewed);

    final failure = (await getProducts(client)).toFailure();

    expect(failure, isA<ValidationFailure>());
    expect((failure as ValidationFailure)['quantity'], 'Use no máximo 3 casas decimais.');
    expect(failure['name'], 'Informe o nome do produto.');
  });
}
