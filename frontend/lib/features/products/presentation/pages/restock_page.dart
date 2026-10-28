import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/inline_message.dart';
import '../../../../core/widgets/numeric_keypad.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';
import '../../domain/products_repository.dart';
import '../controllers/restock_controller.dart';
import '../widgets/product_summary_tile.dart';

class RestockPage extends StatelessWidget {
  const RestockPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RestockController(context.read<ProductsRepository>(), productId)..load(),
      child: const _RestockView(),
    );
  }
}

class _RestockView extends StatelessWidget {
  const _RestockView();

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final saved = await context.read<RestockController>().save();
    if (!saved || !context.mounted) return;
    showAppToast(context, l10n.restockDone);
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<RestockController>();
    final product = controller.product;

    final Widget body;
    if (product != null) {
      body = KeypadLayout(
        keypad: NumericKeypad(onKey: controller.onKey, allowDecimal: product.soldByWeight),
        content: _RestockContent(product: product, controller: controller, onSave: () => _save(context)),
      );
    } else if (controller.loadFailure != null) {
      body = ErrorView(message: l10n.productLoadFailed, onRetry: controller.load);
    } else {
      body = const LoadingView();
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(title: l10n.restockTitle, onBack: () => context.pop()),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _RestockContent extends StatelessWidget {
  const _RestockContent({required this.product, required this.controller, required this.onSave});

  final Product product;
  final RestockController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final colors = context.colors;
    final unit = product.soldByWeight ? l10n.unitKg : l10n.unitPiece;
    final amount = controller.amount;
    // Prévia só para o usuário conferir; quem soma de verdade é o servidor
    final preview = quantityLabel(
      l10n,
      QuantityFormat.format(product.quantity + amount, soldByWeight: product.soldByWeight),
      soldByWeight: product.soldByWeight,
    );
    final failure = controller.saveFailure;

    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.xl, spacing.md + 2, spacing.xl, spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductSummaryTile(product: product),
          SizedBox(height: spacing.lg),
          Text(
            l10n.restockAmountLabel,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  l10n.restockAmount(controller.amountText.isEmpty ? '0' : controller.amountText),
                  style: context.text.headlineLarge?.copyWith(color: controller.amountText.isEmpty ? colors.placeholder : colors.ink),
                ),
                SizedBox(width: spacing.sm),
                Text(unit, style: context.text.titleLarge?.copyWith(color: colors.muted)),
              ],
            ),
          ),
          Text(
            amount > 0 ? l10n.restockNewTotal(preview) : '',
            textAlign: TextAlign.center,
            style: context.text.titleSmall?.copyWith(color: colors.successStrong),
          ),
          if (failure != null) ...[SizedBox(height: spacing.sm), InlineError(failureMessage(l10n, failure), textAlign: TextAlign.center)],
          SizedBox(height: spacing.lg),
          AppButton(
            label: l10n.restockConfirm,
            isActive: controller.canSave,
            isLoading: controller.isSaving,
            onPressed: controller.canSave ? onSave : null,
          ),
        ],
      ),
    );
  }
}
