import '../../../core/network/json_reader.dart';
import '../../../core/utils/date_only.dart';
import '../domain/statement_entry.dart';
import '../domain/store.dart';

abstract final class StoreDto {
  static Store fromJson(Map<String, dynamic> json) {
    return Store(
      id: json.requireString('id'),
      merchantName: json.requireString('merchantName'),
      customerName: json.requireString('customerName'),
      balanceCents: json.requireInt('balanceCents'),
      creditDueDate: DateOnly.tryParse(json.optionalString('creditDueDate')),
    );
  }
}

abstract final class StatementDto {
  static StatementPage fromJson(Map<String, dynamic> json) {
    return StatementPage(
      items: json.requireMapList('items').map(_entry).toList(growable: false),
      total: json.requireInt('total'),
      offset: json.requireInt('offset'),
    );
  }

  static StatementEntry _entry(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json.requireString('createdAt'));
    if (createdAt == null) throw const FormatException('Campo "createdAt" inválido.');
    return StatementEntry(
      id: json.requireString('id'),
      kind: json.requireString('kind') == 'payment' ? StatementKind.payment : StatementKind.purchase,
      amountCents: json.requireInt('amountCents'),
      // Forma nova no servidor não derruba a lista: aparece como pagamento sem forma
      paymentMethod: PaymentMethod.values.asNameMap()[json.optionalString('paymentMethod')] ?? PaymentMethod.unknown,
      createdAt: createdAt.toLocal(),
    );
  }
}
