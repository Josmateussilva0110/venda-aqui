import 'package:flutter/foundation.dart';

/// Compra fiado aumenta a dívida; pagamento diminui.
enum StatementKind { purchase, payment }

enum PaymentMethod { cash, pix, card, credit, unknown }

@immutable
class StatementEntry {
  const StatementEntry({
    required this.id,
    required this.kind,
    required this.amountCents,
    required this.paymentMethod,
    required this.createdAt,
  });

  final String id;
  final StatementKind kind;
  final int amountCents;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
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
