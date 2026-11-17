import '../../../core/network/api_codes.dart';
import '../../../core/network/request_data.dart';
import '../../../core/offline/offline_writer.dart';
import '../../../core/offline/outbox.dart';
import '../domain/customer.dart';

/// Envia os cadastros de cliente feitos sem internet que estão na fila ([Outbox]).
class PendingCustomerSender {
  const PendingCustomerSender();

  static const kind = 'customer';

  /// Corpo do cadastro. [clientId] vira o id do cliente: a venda fiado feita offline para ele já aponta
  /// para esse id, e reenviar o cadastro não cria o cliente duas vezes.
  static Map<String, Object> body(CustomerInput input, {required String clientId}) {
    return {'name': input.name, 'phone': input.phone, 'clientId': clientId};
  }

  static Map<String, dynamic> payload({required Map<String, Object> body}) => {'body': body};

  Future<OutboxResult> send(Map<String, dynamic> payload) async {
    final response = await requestData<void>(endpoint: ApiPaths.customers, method: 'POST', data: payload['body']);
    if (response.success) return (outcome: OutboxOutcome.sent, detail: null, message: null);
    return outboxResultOfFailure(response.toFailure());
  }
}
