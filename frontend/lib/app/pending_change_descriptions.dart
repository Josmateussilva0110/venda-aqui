import '../core/offline/outbox.dart';
import '../core/offline/pending_change_text.dart';
import '../features/customers/data/pending_customer_sender.dart';
import '../features/customers/data/pending_payment_sender.dart';
import '../features/customers/presentation/widgets/pending_payment_notice.dart';
import '../features/products/data/pending_restock_sender.dart';
import '../features/products/presentation/widgets/pending_restock_notice.dart';
import '../features/sales/data/pending_sale_sender.dart';
import '../features/sales/presentation/widgets/pending_sale_notice.dart';
import '../l10n/app_localizations.dart';

/// Liga cada tipo da fila ao texto que a feature dona dele define, para a tela de pendências.
PendingChangeText describePendingChange(AppLocalizations l10n, PendingChange change) {
  return switch (change.kind) {
    PendingSaleSender.kind => pendingSaleText(l10n, change.payload),
    PendingPaymentSender.kind => pendingPaymentText(l10n, change.payload),
    PendingCustomerSender.kind => pendingCustomerText(l10n, change.payload),
    PendingRestockSender.kind => pendingRestockText(l10n, change.payload),
    _ => (title: l10n.pendingChangeUnknown, detail: ''),
  };
}
