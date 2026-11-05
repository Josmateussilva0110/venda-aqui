import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/stock_overview.dart';

/// Fiado a receber no início; o toque abre a lista de quem deve.
class CreditSummaryCard extends StatelessWidget {
  const CreditSummaryCard({super.key, required this.credit, required this.onTap});

  final CreditOverview credit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(spacing.md),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: colors.warningSoft, borderRadius: BorderRadius.circular(context.radius.lg)),
            child: Padding(
              padding: EdgeInsets.all(spacing.sm + 2),
              child: Icon(Icons.menu_book_rounded, color: colors.warning, size: context.sizes.icon),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dashboardCreditTitle, style: context.text.bodySmall),
                Text(MoneyFormat.format(credit.owedCents), style: context.text.titleLarge),
                Text(
                  l10n.debtorsOwingCount(credit.owingCount),
                  style: context.text.labelSmall?.copyWith(color: credit.owingCount > 0 ? colors.danger : colors.muted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.subtle),
        ],
      ),
    );
  }
}
