import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:vendaqui/core/network/api_client.dart';

/// API falsa para testes de rede: responde cada requisição com a próxima resposta da fila
/// (nula simula queda de conexão) e guarda o que foi enviado.
class ScriptedApi implements HttpClientAdapter {
  ScriptedApi() {
    configureApi(Dio()..httpClientAdapter = this);
  }

  final List<(int, Map<String, Object?>)?> responses = [];
  final List<RequestOptions> requests = [];

  Map<String, dynamic> bodyOf(int index) => Map<String, dynamic>.from(requests[index].data as Map);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final response = responses.isEmpty ? null : responses.removeAt(0);
    if (response == null) throw DioException.connectionError(requestOptions: options, reason: 'offline');
    final (status, body) = response;
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
