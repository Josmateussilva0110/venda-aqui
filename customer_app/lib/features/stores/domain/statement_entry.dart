import 'package:flutter/foundation.dart';

/// Compra fiado aumenta a dívida; pagamento diminui.
enum StatementKind { purchase, payment }

enum PaymentMethod { cash, pix, card, credit, unknown }

/// Item de uma compra, com o valor gravado na venda (preço da época).
@immutable
class PurchaseItem {
  const PurchaseItem({required this.name, required this.quantity, required this.soldByWeight, required this.subtotalCents});

  final String name;
  final double quantity;
  final bool soldByWeight;
  final int subtotalCents;
}

@immutable
class StatementEntry {
  const StatementEntry({
    required this.id,
    required this.kind,
    required this.amountCents,
    required this.paymentMethod,
    required this.createdAt,
    this.items = const [],
  });

  final String id;
  final StatementKind kind;
  final int amountCents;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;

  /// O que foi comprado; vazio nos pagamentos.
  final List<PurchaseItem> items;
}

/// Uma página do extrato, como o servidor paginou.
@immutable
class StatementPage {
  const StatementPage({required this.items, required this.total, required this.offset});

  final List<StatementEntry> items;
  final int total;
  final int offset;

  bool get hasMore => offset + items.length < total;
}
