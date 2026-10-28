import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/stock_overview.dart';

/// Cartão verde de destaque. Na Iteração 1 resume o estoque (o faturamento chega com as vendas).
class StockSummaryCard extends StatelessWidget {
  const StockSummaryCard({super.key, required this.overview, required this.onTap});

  final StockOverview overview;
  final VoidCallback onTap;

  static const _decorLargeSize = 170.0;
  static const _decorSmallSize = 110.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = BorderRadius.circular(context.radius.xxl);
    final attention = [
      if (overview.lowCount > 0) l10n.dashboardLowCount(overview.lowCount),
      if (overview.outCount > 0) l10n.dashboardOutCount(overview.outCount),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(color: colors.primary.withValues(alpha: 0.45), blurRadius: 30, offset: const Offset(0, 14), spreadRadius: -14),
        ],
      ),
      child: Material(
        color: colors.primary,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              const Positioned(right: -40, top: -50, child: _DecorCircle(size: _decorLargeSize, alpha: 0.06)),
              const Positioned(right: 30, top: 40, child: _DecorCircle(size: _decorSmallSize, alpha: 0.05)),
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.lg + 2, spacing.lg + 2, spacing.lg + 2, spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.inventory_2_rounded, size: context.sizes.iconSmall, color: colors.primaryTint),
                        SizedBox(width: spacing.xs + 2),
                        Text(
                          l10n.dashboardStockCardTitle,
                          style: context.text.bodySmall?.copyWith(color: colors.primaryTint, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.xs + 2),
                    Text(
                      l10n.dashboardProductCount(overview.totalProducts),
                      style: context.text.displaySmall?.copyWith(color: colors.onPrimary, fontSize: 32),
                    ),
                    SizedBox(height: spacing.xs + 2),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: spacing.sm + 2, vertical: spacing.xs),
                      decoration: BoxDecoration(
                        color: colors.onPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(context.radius.pill),
                      ),
                      child: Text(
                        attention.isEmpty ? l10n.dashboardAllGood : attention.join(' · '),
                        style: context.text.labelSmall?.copyWith(color: colors.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.onPrimary.withValues(alpha: alpha),
      ),
    );
  }
}
