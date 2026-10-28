import 'package:flutter/material.dart';

import '../../../../core/stock/stock_level.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/stock_overview.dart';

class StockAlertsCard extends StatelessWidget {
  const StockAlertsCard({super.key, required this.alerts, required this.onRestock});

  final List<StockAlert> alerts;
  final ValueChanged<StockAlert> onRestock;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.md + 2, vertical: context.spacing.xs),
      child: Column(
        children: [
          for (final (index, alert) in alerts.indexed) ...[
            if (index > 0) const Divider(),
            _AlertRow(alert: alert, onRestock: () => onRestock(alert)),
          ],
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert, required this.onRestock});

  final StockAlert alert;
  final VoidCallback onRestock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final palette = stockLevelColors(context, alert.level);
    final status = alert.level == StockLevel.low
        ? l10n.stockRemaining(
            quantityLabel(l10n, QuantityFormat.format(alert.quantity, soldByWeight: alert.soldByWeight), soldByWeight: alert.soldByWeight),
          )
        : stockLevelLabel(l10n, alert.level);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.sm + 2),
      child: Row(
        children: [
          ProductAvatar(name: alert.name, colorSeed: alert.productId, photoUrl: alert.photoUrl, size: context.sizes.avatar),
          SizedBox(width: context.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: context.spacing.xxs),
                Text(
                  status,
                  style: context.text.bodySmall?.copyWith(color: palette.pillForeground, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onRestock,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primarySoft,
              foregroundColor: colors.primary,
              textStyle: context.text.labelMedium,
              minimumSize: Size(context.sizes.minTouchTarget, context.sizes.minTouchTarget - context.spacing.sm),
            ),
            child: Text(l10n.restockAction),
          ),
        ],
      ),
    );
  }
}
