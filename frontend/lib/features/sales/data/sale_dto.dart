import '../../../core/network/json_reader.dart';
import '../domain/sale.dart';

/// Leitura defensiva da venda como a API devolve (histórico, detalhe e extrato usam o mesmo formato).
abstract final class SaleDto {
  static Sale fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];
    return Sale(
      id: json.requireString('id'),
      createdAt: DateTime.parse(json.requireString('createdAt')).toLocal(),
      editedAt: _optionalDate(json.optionalString('editedAt')),
      method: _methodFromJson(json.optionalString('paymentMethod')),
      totalCents: json.requireInt('totalCents'),
      customer: customer is Map<String, dynamic>
          ? SaleCustomer(id: customer.requireString('id'), name: customer.requireString('name'))
          : null,
      items: json.requireMapList('items').map(_itemFromJson).toList(growable: false),
    );
  }

  static SaleItem _itemFromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json.optionalString('productId'),
      name: json.requireString('name'),
      unitPriceCents: json.requireInt('unitPriceCents'),
      quantity: json.requireDouble('quantity'),
      soldByWeight: json.optionalBool('soldByWeight'),
    );
  }

  /// Corpo do registro e da edição: só produto e quantidade; preço e total saem do servidor.
  static Map<String, dynamic> toJson(SaleInput input) {
    return {
      'paymentMethod': input.method.apiValue,
      if (input.method == PaymentMethod.credit) 'customerId': input.customer?.id,
      'items': [
        for (final item in input.items) {'productId': item.productId, 'quantity': item.quantity},
      ],
    };
  }

  static PaymentMethod _methodFromJson(String? value) {
    final method = PaymentMethod.fromApi(value);
    if (method == null) throw FormatException('Forma de pagamento desconhecida: $value');
    return method;
  }

  static DateTime? _optionalDate(String? value) => value == null ? null : DateTime.tryParse(value)?.toLocal();
}
