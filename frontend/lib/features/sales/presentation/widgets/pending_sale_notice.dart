import '../../../../core/offline/outbox.dart';
import '../../../../core/offline/pending_change_text.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/pending_sale_sender.dart';
import '../../domain/sale.dart';
import 'payment_method_style.dart';

/// Texto do aviso quando uma venda feita sem internet sobe: faltou estoque ou o servidor recusou.
/// Nulo quando não há o que avisar. [formatMoment] formata a hora do balcão no idioma da tela.
String? pendingSaleNotice(AppLocalizations l10n, OutboxEvent event, String Function(DateTime moment) formatMoment) {
  switch (event.outcome) {
    case OutboxOutcome.sent:
      final detail = event.detail;
      if (detail is! PendingSaleReceipt || detail.shortfalls.isEmpty) return null;
      final products = detail.shortfalls
          .map((item) => '${item.name} (${QuantityFormat.format(item.missingQuantity, soldByWeight: item.soldByWeight)})')
          .join(', ');
      return l10n.pendingSaleShortfall(formatMoment(detail.soldAt), products);
    case OutboxOutcome.rejected:
      final soldAt = DateTime.tryParse('${PendingSaleSender.bodyOf(event.payload)['soldAt']}')?.toLocal();
      return l10n.pendingSaleRejected(soldAt == null ? '' : formatMoment(soldAt), event.message ?? l10n.pendingChangeRejectedFallback);
    case OutboxOutcome.retryLater:
      return null;
  }
}

/// Como uma venda guardada aparece na lista de pendências: total, forma de pagamento, itens e cliente.
PendingChangeText pendingSaleText(AppLocalizations l10n, Map<String, dynamic> payload) {
  final total = displayField<int>(payload, 'totalCents');
  final method = PaymentMethod.fromApi(displayField<String>(payload, 'method'));
  final itemCount = displayField<int>(payload, 'itemCount');
  final customer = displayField<String>(payload, 'customerName');
  return (
    title: total == null ? l10n.pendingSaleTitleUnknown : l10n.pendingSaleTitle(MoneyFormat.format(total)),
    detail: [
      ?method?.label(l10n),
      if (itemCount != null) l10n.cartItemCount(itemCount),
      if (customer != null && customer.isNotEmpty) customer,
    ].join(' · '),
  );
}
