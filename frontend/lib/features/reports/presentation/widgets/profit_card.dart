import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sales_report.dart';

/// Destaque verde: lucro líquido do período e a margem.
class ProfitCard extends StatelessWidget {
  const ProfitCard({super.key, required this.report});

  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final margin = report.marginPercent;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(context.radius.xxl)),
      child: Padding(
        padding: EdgeInsets.all(spacing.lg + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportsProfit,
              style: context.text.bodySmall?.copyWith(color: colors.primaryTint, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: spacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(MoneyFormat.format(report.profitCents), style: context.text.displayMedium?.copyWith(color: colors.onPrimary)),
            ),
            SizedBox(height: spacing.xs),
            Text(
              margin == null ? l10n.reportsNoSales : l10n.reportsMargin(margin),
              style: context.text.bodySmall?.copyWith(color: colors.onPrimaryMuted),
            ),
          ],
        ),
      ),
    );
  }
}
