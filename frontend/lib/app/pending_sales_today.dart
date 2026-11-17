import '../core/offline/outbox.dart';
import '../core/offline/pending_change_text.dart';
import '../features/dashboard/domain/stock_overview.dart';
import '../features/sales/data/pending_sale_sender.dart';

/// Vendas feitas sem internet que ainda estão na fila, no formato das vendas recentes do início.
/// Fica no app porque liga duas features: o formato da fila é das vendas, a soma do dia é do início.
/// Recusadas não entram: o servidor não vai registrá-las.
PendingSalesSource pendingSalesToday(Outbox outbox) {
  return (from, until) async {
    final changes = await outbox.list();
    return [
      for (final change in changes)
        if (change.kind == PendingSaleSender.kind &&
            !change.rejected &&
            !change.createdAt.isBefore(from) &&
            change.createdAt.isBefore(until))
          RecentSale(
            id: change.id,
            productNames: displayField<List<dynamic>>(change.payload, 'productNames')?.whereType<String>().toList() ?? const [],
            createdAt: change.createdAt.toLocal(),
            paymentMethod: displayField<String>(change.payload, 'method') ?? '',
            totalCents: displayField<int>(change.payload, 'totalCents') ?? 0,
            customerName: displayField<String>(change.payload, 'customerName'),
            pendingSync: true,
          ),
    ];
  };
}
