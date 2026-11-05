import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sales_report.dart';

/// Conta do lucro: total vendido − custo dos produtos = lucro.
class ProfitBreakdownCard extends StatelessWidget {
  const ProfitBreakdownCard({super.key, required this.report});

  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.lg, vertical: context.spacing.xs),
      child: Column(
        children: [
          _BreakdownRow(
            title: l10n.reportsRevenue,
            subtitle: l10n.reportsSaleCount(report.saleCount),
            value: MoneyFormat.format(report.revenueCents),
            valueStyle: context.text.titleMedium,
          ),
          const Divider(),
          _BreakdownRow(
            title: l10n.reportsCost,
            subtitle: l10n.reportsCostHint,
            value: l10n.reportsCostValue(MoneyFormat.format(report.costCents)),
            valueStyle: context.text.titleMedium?.copyWith(color: colors.danger),
          ),
          const Divider(),
          _BreakdownRow(
            title: l10n.reportsProfitLine,
            value: MoneyFormat.format(report.profitCents),
            valueStyle: context.text.titleMedium?.copyWith(color: colors.primary),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.title, required this.value, required this.valueStyle, this.subtitle});

  final String title;
  final String? subtitle;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall),
                if (subtitle != null) Text(subtitle, style: context.text.bodySmall),
              ],
            ),
          ),
          SizedBox(width: context.spacing.sm),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
