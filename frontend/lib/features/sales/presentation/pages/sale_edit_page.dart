import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/utils/quantity_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';
import '../../domain/sales_repository.dart';
import '../controllers/sale_edit_controller.dart';
import '../widgets/payment_method_style.dart';
import '../widgets/quantity_stepper.dart';

/// Editar venda: a tela recebe a venda já carregada no detalhe e devolve a venda salva ao sair.
class SaleEditPage extends StatelessWidget {
  const SaleEditPage({super.key, required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SaleEditController(context.read<SalesRepository>(), context.read<StockChanges>(), sale),
      child: const _SaleEditView(),
    );
  }
}

class _SaleEditView extends StatelessWidget {
  const _SaleEditView();

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<SaleEditController>();
    final saved = await controller.save();
    if (!context.mounted) return;
    if (saved == null) {
      final failure = controller.failure;
      final message = switch (controller.issue) {
        SaleEditIssue.noItems => l10n.saleEditNoItems,
        SaleEditIssue.missingCustomer => l10n.saleEditMissingCustomer,
        SaleEditIssue.deletedProduct => l10n.saleEditDeletedProduct,
        null => failure == null ? null : failureMessage(l10n, failure),
      };
      if (message != null) showAppToast(context, message, tone: ToastTone.error);
      return;
    }
    showAppToast(context, l10n.saleEditSaved);
    context.pop(saved);
  }

  Future<void> _chooseCustomer(BuildContext context) async {
    final controller = context.read<SaleEditController>();
    final CustomerPickerRequest request = (amountCents: controller.totalCents, itemCount: null, initialCustomerId: controller.customer?.id);
    final picked = await context.push<PickedCustomer>(AppRoutes.customerPicker, extra: request);
    if (picked != null) controller.selectCustomer(SaleCustomer(id: picked.id, name: picked.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final controller = context.watch<SaleEditController>();
    final items = controller.items;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.saleEditTitle, onBack: () => context.pop(), buttonBackground: colors.surface),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.xl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionHeader(title: l10n.saleDetailProducts),
                        SizedBox(height: spacing.md),
                        for (final (index, item) in items.indexed) ...[
                          _EditItemCard(
                            // A chave acompanha o produto: remover um item não mistura o campo de peso do vizinho
                            key: ValueKey(item.productId ?? 'deleted-$index'),
                            item: item,
                            onQuantity: (quantity) => controller.setQuantity(index, quantity),
                            onRemove: () => controller.remove(index),
                          ),
                          SizedBox(height: spacing.sm + 2),
                        ],
                        SizedBox(height: spacing.md),
                        SectionHeader(title: l10n.saleEditMethod),
                        SizedBox(height: spacing.md),
                        Wrap(
                          spacing: spacing.sm,
                          runSpacing: spacing.sm,
                          children: [
                            for (final method in PaymentMethod.values)
                              FilterPill(
                                label: method.label(l10n),
                                selected: controller.method == method,
                                onTap: () => controller.selectMethod(method),
                              ),
                          ],
                        ),
                        if (controller.method == PaymentMethod.credit) ...[
                          SizedBox(height: spacing.xl),
                          SectionHeader(title: l10n.saleEditCustomer),
                          SizedBox(height: spacing.md),
                          _CreditCustomerCard(customer: controller.customer, onChoose: () => _chooseCustomer(context)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _EditFooter(totalCents: controller.totalCents, isSaving: controller.isSaving, onSave: () => _save(context)),
          ],
        ),
      ),
    );
  }
}

/// Cliente do fiado na edição: mostra o escolhido e abre a escolha.
class _CreditCustomerCard extends StatelessWidget {
  const _CreditCustomerCard({required this.customer, required this.onChoose});

  final SaleCustomer? customer;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final customer = this.customer;
    if (customer == null) {
      return AppButton(
        label: l10n.saleEditChooseCustomer,
        icon: Icons.person_search_rounded,
        variant: AppButtonVariant.outlined,
        compact: true,
        onPressed: onChoose,
      );
    }
    return AppCard(
      onTap: onChoose,
      padding: EdgeInsets.all(spacing.md),
      child: Row(
        children: [
          Icon(Icons.person_rounded, color: context.colors.warning),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(customer.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(l10n.saleEditChangeCustomer, style: context.text.labelMedium?.copyWith(color: context.colors.primary)),
        ],
      ),
    );
  }
}

class _EditItemCard extends StatelessWidget {
  const _EditItemCard({super.key, required this.item, required this.onQuantity, required this.onRemove});

  final SaleItem item;
  final ValueChanged<double> onQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final unit = item.soldByWeight ? l10n.unitKg : l10n.unitPiece;
    return AppCard(
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(l10n.sellUnitPrice(MoneyFormat.format(item.unitPriceCents), unit), style: context.text.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: l10n.summaryRemove,
                icon: Icon(Icons.delete_outline_rounded, color: context.colors.subtle, size: context.sizes.icon),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            children: [
              Text(MoneyFormat.format(item.subtotalCents), style: context.text.titleSmall?.copyWith(color: context.colors.primary)),
              if (item.soldByWeight)
                _WeightInput(initial: item.quantity, onChanged: onQuantity)
              else
                QuantityStepper(
                  quantity: item.quantity.round(),
                  onDecrease: () => onQuantity(item.quantity - 1),
                  onIncrease: () => onQuantity(item.quantity + 1),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Peso editável no próprio card (teclado numérico do sistema).
class _WeightInput extends StatefulWidget {
  const _WeightInput({required this.initial, required this.onChanged});

  final double initial;
  final ValueChanged<double> onChanged;

  @override
  State<_WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends State<_WeightInput> {
  final _formatter = QuantityInputFormatter(decimal: true);
  late final _controller = TextEditingController(text: QuantityFormat.format(widget.initial, soldByWeight: true));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: context.sizes.weightInputWidth,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_formatter],
        textAlign: TextAlign.end,
        style: context.text.titleSmall,
        onChanged: (text) => widget.onChanged(QuantityFormat.parse(text) ?? 0),
        decoration: InputDecoration(isDense: true, suffixText: l10n.unitKg, hintText: l10n.quantityHint),
      ),
    );
  }
}

class _EditFooter extends StatelessWidget {
  const _EditFooter({required this.totalCents, required this.isSaving, required this.onSave});

  final int totalCents;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.xl, spacing.sm, spacing.xl, spacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.saleEditNewTotal, style: context.text.titleMedium)),
                Text(MoneyFormat.format(totalCents), style: context.text.titleLarge?.copyWith(color: context.colors.primary)),
              ],
            ),
            SizedBox(height: spacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(label: l10n.cancel, variant: AppButtonVariant.outlined, onPressed: () => context.pop()),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: AppButton(label: l10n.saleEditSave, isLoading: isSaving, onPressed: onSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
