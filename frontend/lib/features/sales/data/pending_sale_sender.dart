import '../../../core/network/api_codes.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../../../core/offline/offline_writer.dart';
import '../../../core/offline/outbox.dart';
import '../domain/sale.dart';

/// Envia as vendas feitas sem internet que estão na fila ([Outbox]).
class PendingSaleSender {
  const PendingSaleSender();

  static const kind = 'sale';

  /// O que vai para a fila: o corpo da requisição e o resumo que a tela de pendências mostra.
  static Map<String, dynamic> payload({required Map<String, dynamic> body, required SaleInput input, required int totalCents}) {
    return {
      'body': body,
      'display': {
        'totalCents': totalCents,
        'itemCount': input.items.fold(0, (sum, item) => sum + (item.soldByWeight ? 1 : item.quantity.round())),
        'method': input.method.apiValue,
        'customerName': input.customer?.name,
      },
    };
  }

  /// Corpo da requisição. Vendas guardadas antes do resumo existir têm o corpo direto no payload.
  static Map<String, dynamic> bodyOf(Map<String, dynamic> payload) {
    final body = payload['body'];
    return body is Map<String, dynamic> ? body : payload;
  }

  Future<OutboxResult> send(Map<String, dynamic> payload) async {
    final body = bodyOf(payload);
    final response = await requestData<List<StockShortfall>>(
      endpoint: ApiPaths.sales,
      method: 'POST',
      data: body,
      parse: (json) => jsonMap(json).requireMapList('stockShortfalls').map(_shortfallFromJson).toList(growable: false),
    );
    final shortfalls = response.data;
    if (response.success && shortfalls != null) {
      final soldAt = DateTime.tryParse('${body['soldAt']}')?.toLocal() ?? DateTime.now();
      return (outcome: OutboxOutcome.sent, detail: PendingSaleReceipt(soldAt: soldAt, shortfalls: shortfalls), message: null);
    }

    return outboxResultOfFailure(response.toFailure());
  }

  static StockShortfall _shortfallFromJson(Map<String, dynamic> json) {
    final missing = json.requireDouble('missingQuantity');
    return StockShortfall(
      name: json.requireString('name'),
      missingQuantity: missing,
      // A resposta não diz como o produto é vendido: quantidade quebrada só existe em produto por peso
      soldByWeight: missing != missing.truncateToDouble(),
    );
  }
}
