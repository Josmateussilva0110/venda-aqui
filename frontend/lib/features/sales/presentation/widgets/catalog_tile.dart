import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';

/// Card de produto na grade da venda: toque soma 1, segurar abre o peso (produtos por kg).
class CatalogTile extends StatelessWidget {
  const CatalogTile({super.key, required this.product, required this.cartQuantity, required this.onTap, this.onLongPress});

  final CatalogProduct product;
  final double cartQuantity;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final inCart = cartQuantity > 0;
    final unit = product.soldByWeight ? l10n.unitKg : l10n.unitPiece;
    final stock = product.isOutOfStock
        ? l10n.sellNoStock
        : l10n.sellStock(
            quantityLabel(
              l10n,
              QuantityFormat.format(product.quantity, soldByWeight: product.soldByWeight),
              soldByWeight: product.soldByWeight,
            ),
          );
    final cartLabel = QuantityFormat.format(cartQuantity, soldByWeight: product.soldByWeight);
    final radius = BorderRadius.circular(context.radius.xxl);

    return Semantics(
      button: true,
      label: [product.name, if (inCart) l10n.sellInCart(cartLabel)].join(', '),
      excludeSemantics: true,
      child: Opacity(
        opacity: product.isOutOfStock ? 0.5 : 1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: inCart ? colors.primary : colors.surface, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                child: Padding(
                  padding: EdgeInsets.all(spacing.sm + 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TileImage(product: product, l10n: l10n),
                      SizedBox(height: spacing.sm),
                      Text(product.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: spacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.sellUnitPrice(MoneyFormat.format(product.salePriceCents), unit),
                                  style: context.text.titleSmall?.copyWith(color: colors.primary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(stock, style: context.text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          SizedBox(width: spacing.xs),
                          DecoratedBox(
                            decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                            child: Padding(
                              padding: EdgeInsets.all(spacing.xs + 2),
                              child: Icon(Icons.add_rounded, size: context.sizes.iconSmall, color: colors.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (inCart)
              Positioned(
                top: -spacing.xs,
                right: -spacing.xs,
                child: _CartBadge(label: cartLabel),
              ),
          ],
        ),
      ),
    );
  }
}

class _TileImage extends StatelessWidget {
  const _TileImage({required this.product, required this.l10n});

  final CatalogProduct product;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final height = context.sizes.catalogImageHeight;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => ProductAvatar(
              name: product.name,
              colorSeed: product.id,
              photoUrl: product.photoUrl,
              size: constraints.maxWidth,
              height: height,
              initialsStyle: context.text.headlineSmall,
            ),
          ),
          if (product.isOutOfStock)
            _TileTag(label: l10n.sellOutOfStock, background: colors.danger, foreground: colors.onPrimary)
          else if (product.soldByWeight)
            _TileTag(label: l10n.sellByWeight, background: colors.surface, foreground: colors.primary),
        ],
      ),
    );
  }
}

class _TileTag extends StatelessWidget {
  const _TileTag({required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xs + 2),
        child: DecoratedBox(
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(context.radius.pill)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.spacing.sm, vertical: context.spacing.xxs),
            child: Text(
              label,
              style: context.text.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quantidade já no carrinho, no canto do card.
class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = context.sizes.cartBadge;
    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xs + 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(context.radius.pill),
        border: Border.all(color: colors.surface, width: 3),
      ),
      child: Text(label, style: context.text.labelMedium?.copyWith(color: colors.onPrimary)),
    );
  }
}
