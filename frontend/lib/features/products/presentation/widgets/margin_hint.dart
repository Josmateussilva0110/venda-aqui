import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../l10n/app_localizations.dart';

/// Lucro por unidade só para orientar quem preenche; o relatório real é calculado no servidor.
class MarginHint extends StatelessWidget {
  const MarginHint({super.key, required this.salePriceCents, required this.costPriceCents, required this.unit});

  final int salePriceCents;
  final int costPriceCents;
  final String unit;

  static const _percent = 100;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final profitable = salePriceCents > costPriceCents;
    final profit = salePriceCents - costPriceCents;
    final text = profitable
        ? l10n.productMargin(unit, MoneyFormat.format(profit), (profit * _percent / salePriceCents).round())
        : l10n.productMarginNegative;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.md + 2, vertical: context.spacing.md),
      decoration: BoxDecoration(
        color: profitable ? colors.successSoft : colors.dangerSoft,
        borderRadius: BorderRadius.circular(context.radius.md),
      ),
      child: Text(
        text,
        style: context.text.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: profitable ? colors.success : colors.dangerStrong,
        ),
      ),
    );
  }
}
