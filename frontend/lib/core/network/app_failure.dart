/// Falhas de domínio que as camadas de dados entregam à apresentação.
sealed class AppFailure implements Exception {
  const AppFailure();
}

/// Sem conexão, tempo esgotado ou resposta ilegível.
final class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

/// Erro inesperado do servidor (5xx). O detalhe fica só no log do backend.
final class ServerFailure extends AppFailure {
  const ServerFailure();
}

/// Recusa conhecida da API (4xx) com mensagem pensada para o usuário.
final class RequestFailure extends AppFailure {
  const RequestFailure({required this.statusCode, required this.message, this.code});

  final int statusCode;
  final String message;
  final String? code;
}

/// 422: mensagens por campo, na chave enviada pelo app (ex.: `pin`, `quantity`).
final class ValidationFailure extends AppFailure {
  const ValidationFailure(this.fieldErrors);

  final Map<String, String> fieldErrors;

  String? operator [](String field) => fieldErrors[field];

  String? get firstMessage => fieldErrors.values.isEmpty ? null : fieldErrors.values.first;
}

/// A sessão acabou (revogada, expirada ou inválida) e o usuário precisa entrar de novo.
final class SessionExpiredFailure extends AppFailure {
  const SessionExpiredFailure();
}
