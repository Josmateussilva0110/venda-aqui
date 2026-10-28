import 'package:flutter/foundation.dart';

import 'app_failure.dart';

enum ApiErrorReason {
  /// O servidor respondeu com erro (4xx/5xx).
  serverError,

  /// Sem conexão, tempo esgotado ou servidor fora do ar.
  networkError,

  /// Resposta fora do envelope esperado ou `data` que não pôde ser lido.
  invalidResponse,

  /// A sessão acabou (revogada, expirada) e o app já voltou para o login.
  sessionExpired,

  /// Requisição cancelada pelo próprio app (ex.: busca substituída).
  cancelled,
}

@immutable
class ApiFailure {
  const ApiFailure({required this.reason, this.status});

  final ApiErrorReason reason;
  final int? status;
}

@immutable
class ApiFieldError {
  const ApiFieldError({required this.field, required this.message});

  /// Nome do campo como o app enviou (ex.: `pin`, `quantity`).
  final String field;
  final String message;

  static ApiFieldError? fromJson(Map<String, dynamic> json) {
    final field = json['field'];
    final message = json['message'];
    if (field is! String || message is! String) return null;
    return ApiFieldError(field: field, message: message);
  }
}

/// Resultado de [requestData]: o envelope `{ success, message, code, data, errors }` da API, já tipado.
@immutable
class ApiResponse<T> {
  const ApiResponse._({required this.success, this.message, this.code, this.data, this.errors = const [], this.error});

  const ApiResponse.success({String? message, T? data}) : this._(success: true, message: message, data: data);

  const ApiResponse.failure({String? message, String? code, List<ApiFieldError> errors = const [], required ApiFailure error})
    : this._(success: false, message: message, code: code, errors: errors, error: error);

  /// Monta a resposta a partir do corpo da API; um `data` que não dá para ler vira falha, não exceção.
  factory ApiResponse.fromJson(Map<String, dynamic> body, {int? status, T Function(Object? json)? parse}) {
    final message = body['message'] is String ? body['message'] as String : null;
    if (body['success'] != true) {
      return ApiResponse.failure(
        message: message,
        code: body['code'] is String ? body['code'] as String : null,
        error: ApiFailure(reason: ApiErrorReason.serverError, status: status),
      );
    }
    if (parse == null) return ApiResponse.success(message: message);
    try {
      return ApiResponse.success(message: message, data: parse(body['data']));
    } on Object {
      // Parse defensivo: campo ausente ou com tipo errado não derruba o app
      return ApiResponse.failure(
        message: message,
        error: ApiFailure(reason: ApiErrorReason.invalidResponse, status: status),
      );
    }
  }

  final bool success;

  /// Mensagem do servidor, escrita para o usuário. Nula em falhas de rede: a tela usa o texto localizado.
  final String? message;

  /// Código de erro da API (contrato com o backend), ex.: `PIN_LOCKED`.
  final String? code;
  final T? data;
  final List<ApiFieldError> errors;
  final ApiFailure? error;

  /// Para os data sources: devolve `data` ou lança a [AppFailure] equivalente.
  T requireData() {
    ensureSuccess();
    final value = data;
    if (value == null) throw const ServerFailure();
    return value;
  }

  /// Para endpoints que só respondem com mensagem.
  void ensureSuccess() {
    if (!success) throw toFailure();
  }

  AppFailure toFailure() {
    final failure = error;
    final status = failure?.status ?? 0;
    return switch (failure?.reason) {
      ApiErrorReason.networkError || ApiErrorReason.cancelled => const NetworkFailure(),
      ApiErrorReason.sessionExpired => const SessionExpiredFailure(),
      ApiErrorReason.invalidResponse || null => const ServerFailure(),
      ApiErrorReason.serverError when status == 422 => ValidationFailure({
        for (final fieldError in errors.reversed) fieldError.field: fieldError.message,
      }),
      ApiErrorReason.serverError when status >= 500 || message == null => const ServerFailure(),
      ApiErrorReason.serverError => RequestFailure(statusCode: status, message: message!, code: code),
    };
  }
}
