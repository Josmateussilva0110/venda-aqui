import '../../../core/network/api_codes.dart';
import '../../../core/network/request_data.dart';
import '../../../core/offline/offline_writer.dart';
import '../../../core/offline/outbox.dart';

/// Envia as reposições de estoque feitas sem internet que estão na fila ([Outbox]).
class PendingRestockSender {
  const PendingRestockSender();

  static const kind = 'restock';

  /// O que vai para a fila: o produto (vai na URL), o corpo da requisição e o que o aviso precisa mostrar.
  static Map<String, dynamic> payload({
    required String productId,
    required Map<String, Object> body,
    required String productName,
    required bool soldByWeight,
  }) {
    return {
      'productId': productId,
      'body': body,
      'display': {'name': productName, 'soldByWeight': soldByWeight},
    };
  }

  Future<OutboxResult> send(Map<String, dynamic> payload) async {
    final response = await requestData<void>(
      endpoint: ApiPaths.productRestock('${payload['productId']}'),
      method: 'POST',
      data: payload['body'],
    );
    if (response.success) return (outcome: OutboxOutcome.sent, detail: null, message: null);
    return outboxResultOfFailure(response.toFailure());
  }
}
