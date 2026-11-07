import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';

extension SettlementMethodLabel on SettlementMethod {
  String label(AppLocalizations l10n) => switch (this) {
    SettlementMethod.cash => l10n.paymentCash,
    SettlementMethod.pix => l10n.paymentPix,
    SettlementMethod.card => l10n.paymentCard,
  };
}
