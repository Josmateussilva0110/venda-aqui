import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';

/// Resumo do produto no topo da reposição: foto, nome, quantidade atual e situação.
class ProductSummaryTile extends StatelessWidget {
  const ProductSummaryTile({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final quantity = quantityLabel(
      l10n,
      QuantityFormat.format(product.quantity, soldByWeight: product.soldByWeight),
      soldByWeight: product.soldByWeight,
    );

    return Container(
      padding: EdgeInsets.all(spacing.sm + 2),
      decoration: BoxDecoration(color: context.colors.background, borderRadius: BorderRadius.circular(context.radius.xl)),
      child: Row(
        children: [
          ProductAvatar(name: product.name, colorSeed: product.id, photoUrl: product.listPhotoUrl, size: context.sizes.productTileLarge),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: context.text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: spacing.xxs),
                Wrap(
                  spacing: spacing.xs + 2,
                  runSpacing: spacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.restockCurrent(quantity),
                      style: context.text.bodySmall?.copyWith(color: context.colors.inkSoft, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    StockLevelPill(level: product.stockLevel),
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
