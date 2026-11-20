import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/statement_entry.dart';

/// Uma linha do extrato: compra fiado (aumenta a dívida) ou pagamento (diminui).
class StatementEntryTile extends StatelessWidget {
  const StatementEntryTile({super.key, required this.entry});

  final StatementEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final isPayment = entry.kind == StatementKind.payment;
    final amount = MoneyFormat.format(entry.amountCents);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.md),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: isPayment ? colors.successSoft : colors.surfaceMuted, shape: BoxShape.circle),
            child: Padding(
              padding: EdgeInsets.all(spacing.sm),
              child: Icon(
                isPayment ? Icons.payments_outlined : Icons.shopping_bag_outlined,
                size: context.sizes.iconSmall,
                color: isPayment ? colors.success : colors.inkSoft,
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title(l10n), style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(AppDateFormat.moment(context, entry.createdAt), style: context.text.bodySmall),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          Text(isPayment ? '− $amount' : amount, style: context.text.titleSmall?.copyWith(color: isPayment ? colors.success : colors.ink)),
        ],
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    if (entry.kind == StatementKind.purchase) return l10n.statementPurchase;
    return switch (entry.paymentMethod) {
      PaymentMethod.cash => l10n.statementPaymentWith(l10n.paymentMethodCash),
      PaymentMethod.pix => l10n.statementPaymentWith(l10n.paymentMethodPix),
      PaymentMethod.card => l10n.statementPaymentWith(l10n.paymentMethodCard),
      PaymentMethod.credit || PaymentMethod.unknown => l10n.statementPayment,
    };
  }
}
