import 'package:flutter/widgets.dart';

import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';
import '../controllers/sale_cart_controller.dart';

/// Avisa no toast por que o produto não entrou no carrinho.
void showCartIssue(BuildContext context, CartIssue issue, CatalogProduct product) {
  final l10n = AppLocalizations.of(context);
  final available = quantityLabel(
    l10n,
    QuantityFormat.format(product.quantity, soldByWeight: product.soldByWeight),
    soldByWeight: product.soldByWeight,
  );
  final message = switch (issue) {
    CartIssue.outOfStock => l10n.cartOutOfStock(product.name),
    CartIssue.insufficientStock => l10n.cartInsufficientStock(available),
    CartIssue.invalidQuantity => l10n.cartInvalidQuantity,
  };
  showAppToast(context, message, tone: ToastTone.error);
}
