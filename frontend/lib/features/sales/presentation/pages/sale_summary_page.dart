import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/sale_cart_controller.dart';
import '../widgets/cart_feedback.dart';
import '../widgets/quantity_stepper.dart';
import 'weight_page.dart';

/// Resumo da venda: ajustar quantidades, remover itens e seguir para o pagamento.
class SaleSummaryPage extends StatelessWidget {
  const SaleSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final cart = context.watch<SaleCartController>();
    final lines = cart.lines;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(title: l10n.summaryTitle, onBack: () => context.pop(), buttonBackground: context.colors.surface),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(spacing.lg, spacing.xs, spacing.lg, spacing.lg),
                    itemCount: lines.length + 1,
                    separatorBuilder: (_, _) => SizedBox(height: spacing.sm + 2),
                    itemBuilder: (context, index) {
                      if (index == lines.length) return _AddMoreButton(isEmpty: lines.isEmpty);
                      return _CartLineCard(line: lines[index]);
                    },
                  ),
                ),
              ),
            ),
            _SummaryFooter(itemCount: cart.itemCount, totalCents: cart.totalCents, canFinish: !cart.isEmpty),
          ],
        ),
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final cart = context.read<SaleCartController>();
    final product = line.product;
    final unit = product.soldByWeight ? l10n.unitKg : l10n.unitPiece;

    void change(double quantity) {
      final issue = cart.setQuantity(product, quantity);
      if (issue != null) showCartIssue(context, issue, product);
    }

    return AppCard(
      padding: EdgeInsets.all(spacing.md),
      child: Row(
        children: [
          ProductAvatar(name: product.name, colorSeed: product.id, photoUrl: product.photoUrl, size: context.sizes.productTile),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(product.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      onPressed: () => cart.remove(product.id),
                      tooltip: l10n.summaryRemove,
                      icon: Icon(Icons.delete_outline_rounded, color: colors.subtle, size: context.sizes.icon),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(l10n.sellUnitPrice(MoneyFormat.format(product.salePriceCents), unit), style: context.text.bodySmall),
                SizedBox(height: spacing.xs),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: spacing.sm,
                  runSpacing: spacing.xs,
                  children: [
                    Text(MoneyFormat.format(line.subtotalCents), style: context.text.titleSmall?.copyWith(color: colors.primary)),
                    if (product.soldByWeight)
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.sellWeight, extra: WeightRequest(product: product, replace: true)),
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          side: BorderSide(color: colors.border, width: 1.5),
                          foregroundColor: colors.ink,
                        ),
                        child: Text(
                          l10n.summaryEditWeight(
                            quantityLabel(l10n, QuantityFormat.format(line.quantity, soldByWeight: true), soldByWeight: true),
                          ),
                          style: context.text.labelMedium,
                        ),
                      )
                    else
                      QuantityStepper(
                        quantity: line.quantity.round(),
                        onDecrease: () => change(line.quantity - 1),
                        onIncrease: () => change(line.quantity + 1),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMoreButton extends StatelessWidget {
  const _AddMoreButton({required this.isEmpty});

  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isEmpty) EmptyView(message: l10n.summaryEmpty),
        OutlinedButton(
          onPressed: () => context.go(AppRoutes.sell),
          style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(context.sizes.buttonHeightCompact),
            side: BorderSide(color: colors.dashed, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.radius.xl)),
            foregroundColor: colors.primary,
          ),
          child: Text(l10n.summaryAddMore, style: context.text.titleSmall?.copyWith(color: colors.primary)),
        ),
      ],
    );
  }
}

class _SummaryFooter extends StatelessWidget {
  const _SummaryFooter({required this.itemCount, required this.totalCents, required this.canFinish});

  final int itemCount;
  final int totalCents;
  final bool canFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.radius.sheet)),
        boxShadow: [BoxShadow(color: colors.shadow.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, -8))],
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: spacing.md),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(spacing.xl, spacing.lg, spacing.xl, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(l10n.summaryItems, style: context.text.bodyMedium)),
                      Text(l10n.cartItemCount(itemCount), style: context.text.bodyMedium),
                    ],
                  ),
                  Divider(height: spacing.lg),
                  Row(
                    children: [
                      Text(l10n.summaryTotal, style: context.text.titleMedium),
                      SizedBox(width: spacing.md),
                      // O valor ocupa o resto da linha encostado à direita e encolhe em tela estreita
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(MoneyFormat.format(totalCents), style: context.text.displaySmall?.copyWith(color: colors.primary)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  AppButton(
                    label: l10n.summaryFinish,
                    icon: Icons.check_rounded,
                    isActive: canFinish,
                    onPressed: canFinish ? () => context.push(AppRoutes.sellPayment) : null,
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
