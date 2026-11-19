import '../../../core/network/api_codes.dart';
import '../../../core/network/request_data.dart';
import '../../../core/offline/offline_writer.dart';
import '../../../core/offline/outbox.dart';
import '../domain/customer.dart';

/// Envia os pagamentos de fiado recebidos sem internet que estão na fila ([Outbox]).
class PendingPaymentSender {
  const PendingPaymentSender();

  static const kind = 'payment';

  /// Corpo da requisição. [paidAt] só na fila: é a hora em que o dinheiro foi recebido.
  static Map<String, Object> body({
    required int amountCents,
    required SettlementMethod method,
    required String clientId,
    DateTime? paidAt,
  }) {
    return {
      'amountCents': amountCents,
      'paymentMethod': method.apiValue,
      'clientId': clientId,
      if (paidAt != null) 'paidAt': paidAt.toUtc().toIso8601String(),
    };
  }

  /// O que vai para a fila: o cliente (vai na URL), o corpo e o que o aviso precisa mostrar.
  static Map<String, dynamic> payload({required String customerId, required Map<String, Object> body, required String customerName}) {
    return {
      'customerId': customerId,
      'body': body,
      'display': {'name': customerName},
    };
  }

  Future<OutboxResult> send(Map<String, dynamic> payload) async {
    final response = await requestData<void>(
      endpoint: ApiPaths.customerPayments('${payload['customerId']}'),
      method: 'POST',
      data: payload['body'],
    );
    if (response.success) return (outcome: OutboxOutcome.sent, detail: null, message: null);
    return outboxResultOfFailure(response.toFailure());
  }
}
