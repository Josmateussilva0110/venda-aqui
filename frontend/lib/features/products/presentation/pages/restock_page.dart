import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/stock/stock_changes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/utils/quantity_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
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
      create: (context) => RestockController(context.read<ProductsRepository>(), context.read<StockChanges>(), productId)..load(),
      child: const _RestockView(),
    );
  }
}

class _RestockView extends StatelessWidget {
  const _RestockView();

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<RestockController>();
    final saved = await controller.save();
    if (!context.mounted) return;
    final failure = controller.saveFailure;
    if (!saved) {
      if (failure != null) showAppToast(context, failureMessage(l10n, failure), tone: ToastTone.error);
      return;
    }
    showAppToast(context, l10n.restockDone);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<RestockController>();
    final product = controller.product;

    final Widget body;
    if (product != null) {
      body = SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
            child: _RestockContent(product: product, controller: controller, onSave: () => _save(context)),
          ),
        ),
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
          _AmountField(soldByWeight: product.soldByWeight, unit: unit, onChanged: controller.setAmount, onSubmitted: onSave),
          Text(
            amount > 0 ? l10n.restockNewTotal(preview) : '',
            textAlign: TextAlign.center,
            style: context.text.titleSmall?.copyWith(color: colors.successStrong),
          ),
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

/// Quantidade grande e centralizada ("+ 12 un"), digitada no teclado numérico do sistema.
class _AmountField extends StatefulWidget {
  const _AmountField({required this.soldByWeight, required this.unit, required this.onChanged, required this.onSubmitted});

  final bool soldByWeight;
  final String unit;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  final _controller = TextEditingController();
  late final _formatter = QuantityInputFormatter(decimal: widget.soldByWeight);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final style = context.text.headlineLarge?.copyWith(color: colors.ink);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(l10n.restockAmountSign, style: style),
        Flexible(
          child: IntrinsicWidth(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: widget.onChanged,
              keyboardType: TextInputType.numberWithOptions(decimal: widget.soldByWeight),
              inputFormatters: [_formatter],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => widget.onSubmitted(),
              textAlign: TextAlign.center,
              style: style,
              decoration: InputDecoration(
                hintText: l10n.restockAmountHint,
                hintStyle: style?.copyWith(color: colors.placeholder),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        SizedBox(width: context.spacing.sm),
        Text(widget.unit, style: context.text.titleLarge?.copyWith(color: colors.muted)),
      ],
    );
  }
}
