import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/utils/quantity_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';
import '../controllers/sale_cart_controller.dart';
import '../widgets/cart_feedback.dart';

/// O que a tela de peso recebe: o produto e se é para somar ou trocar o peso já no carrinho.
class WeightRequest {
  const WeightRequest({required this.product, this.replace = false});

  final CatalogProduct product;
  final bool replace;
}

/// Vender por peso: o peso é digitado no teclado do celular, com atalhos de 250 g, 500 g e 1 kg.
class WeightPage extends StatefulWidget {
  const WeightPage({super.key, required this.request});

  final WeightRequest request;

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final _formatter = QuantityInputFormatter(decimal: true);
  late final TextEditingController _weight;

  CatalogProduct get _product => widget.request.product;

  @override
  void initState() {
    super.initState();
    final current = context.read<SaleCartController>().quantityOf(_product.id);
    _weight = TextEditingController(text: widget.request.replace && current > 0 ? QuantityFormat.format(current, soldByWeight: true) : '');
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  double get _value => QuantityFormat.parse(_weight.text) ?? 0;

  void _setQuick(String value) => _weight.value = TextEditingValue(
    text: value,
    selection: TextSelection.collapsed(offset: value.length),
  );

  void _confirm() {
    final l10n = AppLocalizations.of(context);
    final weight = _value;
    if (weight <= 0) return showAppToast(context, l10n.weightRequired, tone: ToastTone.error);

    final cart = context.read<SaleCartController>();
    final total = widget.request.replace ? weight : cart.quantityOf(_product.id) + weight;
    final issue = cart.setQuantity(_product, total);
    if (issue != null) return showCartIssue(context, issue, _product);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.weightTitle, onBack: () => context.pop(), buttonBackground: context.colors.surface),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(spacing.xl, spacing.md, spacing.xl, spacing.xl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProductHeader(product: _product),
                        SizedBox(height: spacing.xl),
                        _WeightField(controller: _weight, formatter: _formatter, onSubmitted: _confirm),
                        ValueListenableBuilder(
                          valueListenable: _weight,
                          builder: (context, _, _) => Text(
                            MoneyFormat.format((_product.salePriceCents * _value).round()),
                            textAlign: TextAlign.center,
                            style: context.text.titleMedium?.copyWith(color: context.colors.primary),
                          ),
                        ),
                        SizedBox(height: spacing.lg),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: spacing.sm,
                          runSpacing: spacing.sm,
                          children: [
                            for (final (value, label) in [
                              ('0,25', l10n.weightQuick250),
                              ('0,5', l10n.weightQuick500),
                              ('1', l10n.weightQuick1kg),
                            ])
                              FilterPill(label: label, selected: false, onTap: () => _setQuick(value)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(spacing.xl, spacing.sm, spacing.xl, spacing.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(label: l10n.cancel, variant: AppButtonVariant.outlined, onPressed: () => context.pop()),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: AppButton(label: widget.request.replace ? l10n.weightUpdate : l10n.weightAdd, onPressed: _confirm),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final stock = quantityLabel(l10n, QuantityFormat.format(product.quantity, soldByWeight: true), soldByWeight: true);
    return Row(
      children: [
        ProductAvatar(name: product.name, colorSeed: product.id, photoUrl: product.photoUrl, size: context.sizes.productTile),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: context.text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(l10n.sellUnitPrice(MoneyFormat.format(product.salePriceCents), l10n.unitKg), style: context.text.bodyMedium),
              Text(l10n.sellStock(stock), style: context.text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// Peso grande e centralizado ("1,250 kg"), digitado no teclado numérico do sistema.
class _WeightField extends StatelessWidget {
  const _WeightField({required this.controller, required this.formatter, required this.onSubmitted});

  final TextEditingController controller;
  final QuantityInputFormatter formatter;
  final VoidCallback onSubmitted;

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
        Flexible(
          child: IntrinsicWidth(
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [formatter],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmitted(),
              textAlign: TextAlign.center,
              style: style,
              decoration: InputDecoration(
                hintText: l10n.quantityHint,
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
        Text(l10n.unitKg, style: context.text.titleLarge?.copyWith(color: colors.muted)),
      ],
    );
  }
}
