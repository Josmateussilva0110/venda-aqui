import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_response.dart';
import 'app_failure.dart';

/// **A única função que fala com o backend.** Recebe o endpoint e cuida de método, token,
/// renovação de sessão (via interceptor), leitura do JSON e normalização de erros.
///
/// Nunca lança: falhas voltam como [ApiResponse] com `success == false`.
///
/// ```dart
/// final response = await requestData<Product>(
///   endpoint: ApiPaths.product(id),
///   parse: (json) => ProductDto.fromJson(json! as Map<String, dynamic>),
/// );
/// if (response.success) print(response.data!.name);
/// ```
///
/// [parse] diz como montar `T` a partir do campo `data`; omita para endpoints que só devolvem mensagem.
/// [client] existe para a renovação de sessão (cliente sem interceptor) e para testes.
/// [cancelToken] permite cancelar uma busca substituída por outra.
Future<ApiResponse<T>> requestData<T>({
  required String endpoint,
  String method = 'GET',
  Object? data,
  Map<String, dynamic>? params,
  Map<String, String>? headers,
  bool withAuth = true,
  T Function(Object? json)? parse,
  CancelToken? cancelToken,
  Dio? client,
}) async {
  try {
    final verb = method.toUpperCase();
    final isGet = verb == 'GET';

    // GET leva tudo na query string; valores nulos ou vazios não são enviados
    final queryParameters = <String, dynamic>{...?params, if (isGet && data is Map) ...data.cast<String, dynamic>()}
      ..removeWhere((_, value) => value == null || value == '');

    final response = await (client ?? api).request<Object?>(
      endpoint,
      data: isGet ? null : data,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
      cancelToken: cancelToken,
      options: Options(method: verb, headers: headers, extra: {ApiRequestFlags.skipAuth: !withAuth}),
    );

    final body = _asMap(response.data);
    if (body == null) {
      return ApiResponse<T>.failure(
        error: ApiFailure(reason: ApiErrorReason.invalidResponse, status: response.statusCode),
      );
    }
    return ApiResponse<T>.fromJson(body, status: response.statusCode, parse: parse);
  } on DioException catch (error) {
    // O interceptor de sessão já decidiu: sessão encerrada ou sem rede para renová-la
    final decided = error.error;
    if (decided is SessionExpiredFailure) {
      return ApiResponse<T>.failure(error: const ApiFailure(reason: ApiErrorReason.sessionExpired, status: 401));
    }
    if (decided is NetworkFailure) {
      return ApiResponse<T>.failure(error: const ApiFailure(reason: ApiErrorReason.networkError));
    }

    final response = error.response;
    // O servidor respondeu (4xx / 5xx)
    if (response != null) {
      final body = _asMap(response.data);
      final errors = _fieldErrors(body);
      return ApiResponse<T>.failure(
        message: errors.isNotEmpty ? errors.first.message : _messageOf(body),
        code: body?['code'] is String ? body!['code'] as String : null,
        errors: errors,
        error: ApiFailure(reason: ApiErrorReason.serverError, status: response.statusCode),
      );
    }

    // Tempo esgotado, DNS, servidor fora do ar ou cancelamento
    return ApiResponse<T>.failure(
      error: ApiFailure(reason: error.type == DioExceptionType.cancel ? ApiErrorReason.cancelled : ApiErrorReason.networkError),
    );
  }
}

Map<String, dynamic>? _asMap(Object? body) {
  return body is Map ? body.cast<String, dynamic>() : null;
}

List<ApiFieldError> _fieldErrors(Map<String, dynamic>? body) {
  final raw = body?['errors'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map<Object?, Object?>>()
      .map((entry) => ApiFieldError.fromJson(entry.cast<String, dynamic>()))
      .whereType<ApiFieldError>()
      .toList(growable: false);
}

/// Lê a mensagem do envelope normal `{ message }` ou do formato aninhado `{ error: { message } }`.
String? _messageOf(Map<String, dynamic>? body) {
  final message = body?['message'];
  if (message is String && message.isNotEmpty) return message;

  final error = body?['error'];
  if (error is Map) {
    final nested = error['message'];
    if (nested is String && nested.isNotEmpty) return nested;
  }
  return null;
}
