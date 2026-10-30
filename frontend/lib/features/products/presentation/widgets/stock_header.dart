import 'package:flutter/material.dart';

import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';

/// Topo branco do estoque: título, resumo, busca e filtros por situação.
class StockHeader extends StatelessWidget {
  const StockHeader({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.filter,
    required this.counts,
    required this.lowStockThreshold,
    required this.onFilter,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final StockFilter filter;
  final StockCounts counts;
  final int lowStockThreshold;
  final ValueChanged<StockFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(context.radius.xxxl)),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(spacing.xl, spacing.lg, spacing.xl, spacing.md + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(header: true, child: Text(l10n.stockTitle, style: context.text.headlineSmall)),
                  SizedBox(height: spacing.xxs),
                  Text(l10n.stockSubtitle(counts.all, lowStockThreshold), style: context.text.bodySmall),
                  SizedBox(height: spacing.md),
                  SearchField(controller: searchController, hint: l10n.searchProductHint, onChanged: onSearch),
                  SizedBox(height: spacing.md),
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.sm,
                    children: [
                      FilterPill(
                        label: l10n.stockFilterAll(counts.all),
                        dotColor: colors.neutralDot,
                        selected: filter == StockFilter.all,
                        onTap: () => onFilter(StockFilter.all),
                      ),
                      FilterPill(
                        label: l10n.stockFilterLow(counts.low),
                        dotColor: colors.warningDot,
                        selected: filter == StockFilter.low,
                        onTap: () => onFilter(StockFilter.low),
                      ),
                      FilterPill(
                        label: l10n.stockFilterOut(counts.out),
                        dotColor: colors.danger,
                        selected: filter == StockFilter.out,
                        onTap: () => onFilter(StockFilter.out),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
