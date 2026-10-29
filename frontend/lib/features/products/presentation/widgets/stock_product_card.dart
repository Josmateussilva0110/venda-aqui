import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';

class StockProductCard extends StatelessWidget {
  const StockProductCard({super.key, required this.product, required this.onOpen, required this.onRestock});

  final Product product;
  final VoidCallback onOpen;
  final VoidCallback onRestock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final palette = stockLevelColors(context, product.stockLevel);
    final radius = BorderRadius.circular(context.radius.xxl);
    final quantity = quantityLabel(
      l10n,
      QuantityFormat.format(product.quantity, soldByWeight: product.soldByWeight),
      soldByWeight: product.soldByWeight,
    );

    return Material(
      color: palette.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.cardBorder, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            children: [
              ProductAvatar(name: product.name, colorSeed: product.id, photoUrl: product.listPhotoUrl, size: context.sizes.productTile),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: context.text.titleSmall?.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xxs + 1),
                    Text.rich(
                      TextSpan(
                        text: l10n.stockSalePrice(MoneyFormat.format(product.salePriceCents)),
                        children: [
                          TextSpan(
                            text: l10n.stockCostPrice(MoneyFormat.format(product.costPriceCents)),
                            style: TextStyle(color: colors.muted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      style: context.text.bodySmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xxs + 1),
                    Wrap(
                      spacing: spacing.xs + 2,
                      runSpacing: spacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(quantity, style: context.text.titleSmall),
                        StockLevelPill(level: product.stockLevel),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              FilledButton(
                onPressed: onRestock,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  textStyle: context.text.labelMedium,
                  minimumSize: Size(context.sizes.minTouchTarget, context.sizes.minTouchTarget - spacing.xs),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.radius.md)),
                ),
                child: Text(l10n.restockAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
