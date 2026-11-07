import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sales_report.dart';

/// Produtos que mais deram lucro, com a barra proporcional ao primeiro colocado.
class ProfitRankingCard extends StatelessWidget {
  const ProfitRankingCard({super.key, required this.ranking});

  final List<ReportRankingItem> ranking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    // Prejuízo não gera barra negativa: a escala parte do maior lucro positivo
    final topProfit = ranking.isEmpty ? 0 : ranking.first.profitCents;
    return AppCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.reportsRankingTitle, style: context.text.titleMedium),
          Text(l10n.reportsRankingHint, style: context.text.bodySmall),
          SizedBox(height: spacing.md),
          if (ranking.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.lg),
              child: Text(l10n.reportsRankingEmpty, textAlign: TextAlign.center, style: context.text.bodyMedium),
            ),
          for (final (index, item) in ranking.indexed) ...[
            if (index > 0) SizedBox(height: spacing.md),
            _RankingRow(position: index + 1, item: item, share: topProfit <= 0 ? 0 : item.profitCents / topProfit),
          ],
          SizedBox(height: spacing.md),
          Text(l10n.reportsFootnote, style: context.text.bodySmall),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.position, required this.item, required this.share});

  // Barra mínima para o produto aparecer mesmo com lucro pequeno perto do primeiro
  static const _minShare = 0.04;

  final int position;
  final ReportRankingItem item;
  final double share;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final isFirst = position == 1;
    final quantity = quantityLabel(
      l10n,
      QuantityFormat.format(item.quantity, soldByWeight: item.soldByWeight),
      soldByWeight: item.soldByWeight,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: isFirst ? colors.primary : colors.surfaceMuted, shape: BoxShape.circle),
              child: SizedBox.square(
                dimension: context.sizes.icon + spacing.sm,
                child: Center(
                  child: Text('$position', style: context.text.labelMedium?.copyWith(color: isFirst ? colors.onPrimary : colors.inkSoft)),
                ),
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    l10n.reportsRankingLine(quantity, MoneyFormat.format(item.revenueCents)),
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Text(
              MoneyFormat.format(item.profitCents),
              style: context.text.titleSmall?.copyWith(color: item.profitCents < 0 ? colors.danger : colors.primary),
            ),
          ],
        ),
        SizedBox(height: spacing.xs + 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(context.radius.pill),
          child: LinearProgressIndicator(
            value: share <= 0 ? 0 : share.clamp(_minShare, 1),
            minHeight: context.sizes.progressBarHeight,
            backgroundColor: colors.surfaceMuted,
            color: isFirst ? colors.primary : colors.primaryTint,
          ),
        ),
      ],
    );
  }
}
