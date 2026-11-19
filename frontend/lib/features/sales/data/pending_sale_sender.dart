import '../../../core/network/api_codes.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../../../core/offline/offline_writer.dart';
import '../../../core/offline/outbox.dart';
import '../../../core/offline/pending_change_text.dart';
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
        'productNames': [for (final item in input.items) item.name],
        'customerId': input.customer?.id,
        // Itens como foram vendidos (preço do catálogo), para o histórico mostrar a venda antes de ela subir
        'items': [
          for (final item in input.items)
            {
              'productId': item.productId,
              'name': item.name,
              'unitPriceCents': item.unitPriceCents,
              'quantity': item.quantity,
              'soldByWeight': item.soldByWeight,
            },
        ],
      },
    };
  }

  /// A venda guardada como o histórico mostra, marcada como ainda não enviada. Vendas guardadas antes
  /// dos itens entrarem no resumo aparecem só com os nomes.
  static Sale saleOf(PendingChange change) {
    final rawItems = displayField<List<dynamic>>(change.payload, 'items');
    final names = displayField<List<dynamic>>(change.payload, 'productNames')?.whereType<String>().toList() ?? const <String>[];
    final items = rawItems == null
        ? [for (final name in names) SaleItem(productId: null, name: name, unitPriceCents: 0, quantity: 1, soldByWeight: false)]
        : [
            for (final item in rawItems.whereType<Map<String, dynamic>>())
              SaleItem(
                productId: item['productId'] as String?,
                name: item['name'] is String ? item['name'] as String : '',
                unitPriceCents: item['unitPriceCents'] is int ? item['unitPriceCents'] as int : 0,
                quantity: item['quantity'] is num ? (item['quantity'] as num).toDouble() : 0,
                soldByWeight: item['soldByWeight'] == true,
              ),
          ];
    final customerName = displayField<String>(change.payload, 'customerName');
    return Sale(
      id: change.id,
      createdAt: change.createdAt.toLocal(),
      items: items,
      method: PaymentMethod.fromApi(displayField<String>(change.payload, 'method')) ?? PaymentMethod.cash,
      totalCents: displayField<int>(change.payload, 'totalCents') ?? 0,
      customer: customerName == null
          ? null
          : SaleCustomer(id: displayField<String>(change.payload, 'customerId') ?? '', name: customerName),
      pendingSync: true,
    );
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
