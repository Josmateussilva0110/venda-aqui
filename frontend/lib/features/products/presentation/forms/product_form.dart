import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/photo_picker.dart';
import '../../domain/product.dart';
import '../widgets/margin_hint.dart';
import '../widgets/money_field.dart';
import '../widgets/photo_picker_box.dart';
import '../widgets/weight_toggle_tile.dart';

/// Formulário único de produto: o cadastro passa [initialValue] nulo, a edição passa o produto.
/// Ele não sabe qual dos dois é; só entrega os dados em [onSubmit].
class ProductForm extends StatefulWidget {
  const ProductForm({
    super.key,
    required this.initialValue,
    required this.submitLabel,
    required this.onSubmit,
    required this.isSaving,
    this.serverFailure,
  });

  final Product? initialValue;
  final String submitLabel;
  final void Function(ProductInput input, ProductPhoto? photo) onSubmit;
  final bool isSaving;
  final AppFailure? serverFailure;

  @override
  State<ProductForm> createState() => _ProductFormState();
}

enum _Field { name, salePrice, costPrice, quantity }

class _ProductFormState extends State<ProductForm> {
  static const _nameMaxLength = 80;

  late final TextEditingController _name;
  late final TextEditingController _salePrice;
  late final TextEditingController _costPrice;
  late final TextEditingController _quantity;
  late bool _soldByWeight;
  ProductPhoto? _photo;
  final Map<_Field, String> _localErrors = {};

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _name = TextEditingController(text: initial?.name ?? '');
    _salePrice = TextEditingController(text: initial == null ? '' : MoneyFormat.toInput(initial.salePriceCents));
    _costPrice = TextEditingController(text: initial == null ? '' : MoneyFormat.toInput(initial.costPriceCents));
    _quantity = TextEditingController(
      text: initial == null ? '' : QuantityFormat.format(initial.quantity, soldByWeight: initial.soldByWeight),
    );
    _soldByWeight = initial?.soldByWeight ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _salePrice.dispose();
    _costPrice.dispose();
    _quantity.dispose();
    super.dispose();
  }

  /// Campo com problema fica com a borda vermelha; a mensagem em si vai para o toast.
  bool _hasError(_Field field, String serverKey) {
    if (_localErrors.containsKey(field)) return true;
    final failure = widget.serverFailure;
    return failure is ValidationFailure && failure[serverKey] != null;
  }

  void _clearError(_Field field) {
    if (_localErrors.remove(field) != null) setState(() {});
  }

  Future<void> _pickPhoto() async {
    final l10n = AppLocalizations.of(context);
    final picker = context.read<PhotoPicker>();
    final origin = await showModalBottomSheet<PhotoOrigin>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(l10n.productPhotoFromCamera),
              onTap: () => Navigator.pop(context, PhotoOrigin.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.productPhotoFromGallery),
              onTap: () => Navigator.pop(context, PhotoOrigin.gallery),
            ),
          ],
        ),
      ),
    );
    if (origin == null) return;

    final result = await picker.pick(origin);
    if (!mounted) return;
    switch (result) {
      case PhotoPicked(:final photo):
        setState(() => _photo = photo);
      case PhotoTooLarge():
        showAppToast(context, l10n.productPhotoTooLarge, tone: ToastTone.error);
      case PhotoUnsupported():
        showAppToast(context, l10n.productPhotoUnsupported, tone: ToastTone.error);
      case PhotoCancelled():
        break;
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final salePrice = MoneyFormat.parseCents(_salePrice.text);
    final costPrice = MoneyFormat.parseCents(_costPrice.text);
    final quantity = QuantityFormat.parse(_quantity.text.isEmpty ? '0' : _quantity.text);
    final quantityValid = quantity != null && (_soldByWeight || quantity == quantity.roundToDouble());

    // Validação só de UX: o backend confere tudo de novo
    setState(() {
      _localErrors
        ..clear()
        ..addAll({
          if (name.isEmpty) _Field.name: l10n.productNameRequired,
          if (salePrice == null || salePrice <= 0) _Field.salePrice: l10n.productSalePriceRequired,
          if (costPrice == null || costPrice <= 0) _Field.costPrice: l10n.productCostPriceRequired,
          if (!quantityValid) _Field.quantity: l10n.productQuantityInvalid,
        });
    });
    if (_localErrors.isNotEmpty) {
      // Um toast por vez: mostra o primeiro problema, na ordem dos campos
      showAppToast(context, _localErrors.values.first, tone: ToastTone.error);
      return;
    }

    widget.onSubmit(
      ProductInput(name: name, salePriceCents: salePrice!, costPriceCents: costPrice!, quantity: quantity!, soldByWeight: _soldByWeight),
      _photo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final unit = _soldByWeight ? l10n.unitKg : l10n.unitPiece;
    final salePrice = MoneyFormat.parseCents(_salePrice.text) ?? 0;
    final costPrice = MoneyFormat.parseCents(_costPrice.text) ?? 0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(spacing.xl, spacing.xs, spacing.xl, spacing.xl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _name,
                      builder: (context, value, _) => PhotoPickerBox(
                        name: value.text,
                        pickedBytes: _photo?.bytes,
                        currentUrl: widget.initialValue?.photoUrl,
                        onTap: _pickPhoto,
                      ),
                    ),
                    SizedBox(height: spacing.md + 2),
                    LabeledField(
                      label: l10n.productNameLabel,
                      child: TextField(
                        controller: _name,
                        maxLength: _nameMaxLength,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => _clearError(_Field.name),
                        style: context.text.bodyLarge,
                        decoration: InputDecoration(
                          hintText: l10n.productNameHint,
                          counterText: '',
                          fillColor: context.colors.surface,
                          error: _hasError(_Field.name, 'name') ? const SizedBox.shrink() : null,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.md + 2),
                    _PriceFields(
                      salePrice: _salePrice,
                      costPrice: _costPrice,
                      saleError: _hasError(_Field.salePrice, 'salePriceCents'),
                      costError: _hasError(_Field.costPrice, 'costPriceCents'),
                      onChanged: (field) => setState(() => _localErrors.remove(field)),
                    ),
                    if (salePrice > 0 && costPrice > 0) ...[
                      SizedBox(height: spacing.md + 2),
                      MarginHint(salePriceCents: salePrice, costPriceCents: costPrice, unit: unit),
                    ],
                    SizedBox(height: spacing.md + 2),
                    NumberField(
                      label: widget.initialValue == null ? l10n.productInitialQuantity : l10n.productStockQuantity,
                      controller: _quantity,
                      hint: l10n.quantityHint,
                      suffix: unit,
                      hasError: _hasError(_Field.quantity, 'quantity'),
                      onChanged: (_) => _clearError(_Field.quantity),
                    ),
                    SizedBox(height: spacing.md + 2),
                    WeightToggleTile(
                      value: _soldByWeight,
                      onChanged: (value) => setState(() {
                        _soldByWeight = value;
                        _localErrors.remove(_Field.quantity);
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _SubmitBar(label: widget.submitLabel, isSaving: widget.isSaving, onSubmit: _submit),
      ],
    );
  }
}

class _PriceFields extends StatelessWidget {
  const _PriceFields({
    required this.salePrice,
    required this.costPrice,
    required this.saleError,
    required this.costError,
    required this.onChanged,
  });

  final TextEditingController salePrice;
  final TextEditingController costPrice;
  final bool saleError;
  final bool costError;
  final ValueChanged<_Field> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sale = NumberField(
      label: l10n.productSalePriceLabel,
      controller: salePrice,
      hint: l10n.moneyHint,
      prefix: currencyPrefix(context),
      hasError: saleError,
      onChanged: (_) => onChanged(_Field.salePrice),
    );
    final cost = NumberField(
      label: l10n.productCostPriceLabel,
      controller: costPrice,
      hint: l10n.moneyHint,
      prefix: currencyPrefix(context),
      hasError: costError,
      onChanged: (_) => onChanged(_Field.costPrice),
    );

    // Lado a lado como no protótipo; empilha quando a largura (ou a fonte) não comporta
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final sideBySide = constraints.maxWidth / scale >= AppBreakpoints.medium / 2;
        if (!sideBySide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              sale,
              SizedBox(height: context.spacing.md + 2),
              cost,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: sale),
            SizedBox(width: context.spacing.md - 2),
            Expanded(child: cost),
          ],
        );
      },
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.label, required this.isSaving, required this.onSubmit});

  final String label;
  final bool isSaving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.radius.xxxl)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: spacing.lg),
        child: Padding(
          padding: EdgeInsets.fromLTRB(spacing.xl, spacing.md, spacing.xl, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(label: label, isLoading: isSaving, onPressed: onSubmit),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
