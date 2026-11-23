import '../../../core/utils/quantity_format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/statement_entry.dart';

/// Textos de um lançamento, os mesmos na tela e no PDF.
extension StatementEntryLabels on StatementEntry {
  String title(AppLocalizations l10n) {
    if (kind == StatementKind.purchase) return l10n.statementPurchase;
    return switch (paymentMethod) {
      PaymentMethod.cash => l10n.statementPaymentWith(l10n.paymentMethodCash),
      PaymentMethod.pix => l10n.statementPaymentWith(l10n.paymentMethodPix),
      PaymentMethod.card => l10n.statementPaymentWith(l10n.paymentMethodCard),
      PaymentMethod.credit || PaymentMethod.unknown => l10n.statementPayment,
    };
  }
}

extension PurchaseItemLabels on PurchaseItem {
  /// "12× Farinha" ou "0,755 kg Tomate".
  String line(AppLocalizations l10n) {
    final amount = QuantityFormat.format(quantity, soldByWeight: soldByWeight);
    return l10n.purchaseItemLine(soldByWeight ? l10n.quantityKg(amount) : l10n.quantityUnits(amount), name);
  }
}
