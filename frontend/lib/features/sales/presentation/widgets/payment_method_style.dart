import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';

/// Nome, descrição, ícone e cores de cada forma de pagamento, num lugar só.
extension PaymentMethodStyle on PaymentMethod {
  String label(AppLocalizations l10n) => switch (this) {
    PaymentMethod.cash => l10n.paymentCash,
    PaymentMethod.pix => l10n.paymentPix,
    PaymentMethod.card => l10n.paymentCard,
    PaymentMethod.credit => l10n.paymentCredit,
  };

  String detail(AppLocalizations l10n) => switch (this) {
    PaymentMethod.cash => l10n.paymentCashDetail,
    PaymentMethod.pix => l10n.paymentPixDetail,
    PaymentMethod.card => l10n.paymentCardDetail,
    PaymentMethod.credit => l10n.paymentCreditDetail,
  };

  IconData get icon => switch (this) {
    PaymentMethod.cash => Icons.payments_rounded,
    PaymentMethod.pix => Icons.qr_code_2_rounded,
    PaymentMethod.card => Icons.credit_card_rounded,
    PaymentMethod.credit => Icons.menu_book_rounded,
  };

  ({Color background, Color foreground}) colors(BuildContext context) {
    final colors = context.colors;
    return switch (this) {
      PaymentMethod.cash => (background: colors.successSoft, foreground: colors.successStrong),
      PaymentMethod.pix => (background: colors.primarySoft, foreground: colors.primary),
      PaymentMethod.card => (background: colors.violetSoft, foreground: colors.violet),
      PaymentMethod.credit => (background: colors.warningSoft, foreground: colors.warning),
    };
  }
}

/// Selo da forma de pagamento usado no histórico e no detalhe.
class PaymentMethodBadge extends StatelessWidget {
  const PaymentMethodBadge({super.key, required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final palette = method.colors(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(context.radius.pill)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.spacing.sm, vertical: context.spacing.xxs),
        child: Text(method.label(AppLocalizations.of(context)), style: context.text.labelSmall?.copyWith(color: palette.foreground)),
      ),
    );
  }
}
