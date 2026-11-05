import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/stock_level_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';
import '../../domain/sales_repository.dart';
import '../controllers/sale_detail_controller.dart';
import '../widgets/payment_method_style.dart';

class SaleDetailPage extends StatelessWidget {
  const SaleDetailPage({super.key, required this.saleId});

  final String saleId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SaleDetailController(context.read<SalesRepository>(), saleId)..load(),
      child: const _SaleDetailView(),
    );
  }
}

class _SaleDetailView extends StatelessWidget {
  const _SaleDetailView();

  Future<void> _edit(BuildContext context, Sale sale) async {
    final controller = context.read<SaleDetailController>();
    final updated = await context.push<Sale>(AppRoutes.saleEdit(sale.id), extra: sale);
    if (updated != null) controller.replace(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<SaleDetailController>();
    final sale = controller.sale;

    final Widget body;
    if (sale != null) {
      body = _SaleContent(sale: sale);
    } else if (controller.failure != null) {
      body = ErrorView(message: l10n.saleLoadFailed, onRetry: controller.load);
    } else {
      body = const LoadingView();
    }

    // Sai devolvendo se a venda foi editada, para o histórico só buscar de novo quando precisa
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(controller.wasEdited);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: l10n.saleDetailTitle,
                onBack: () => context.pop(controller.wasEdited),
                buttonBackground: context.colors.surface,
              ),
              Expanded(child: body),
              if (sale != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(spacing.xl, spacing.sm, spacing.xl, spacing.md),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: l10n.saleDetailEdit,
                        icon: Icons.edit_rounded,
                        variant: AppButtonVariant.outlined,
                        onPressed: () => _edit(context, sale),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaleContent extends StatelessWidget {
  const _SaleContent({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final locale = Localizations.localeOf(context).toString();
    final date = toBeginningOfSentenceCase(DateFormat.MMMMEEEEd(locale).format(sale.createdAt));
    final time = DateFormat.Hm(locale).format(sale.createdAt);
    final editedAt = sale.editedAt;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: EdgeInsets.all(spacing.xl),
                child: Column(
                  children: [
                    Text(l10n.saleDetailTotal, style: context.text.bodyMedium),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(MoneyFormat.format(sale.totalCents), style: context.text.displayMedium?.copyWith(color: colors.primary)),
                    ),
                    Text('$date · $time', textAlign: TextAlign.center, style: context.text.bodySmall),
                    if (editedAt != null)
                      Text(
                        l10n.saleDetailEdited(DateFormat.Md(locale).add_Hm().format(editedAt)),
                        textAlign: TextAlign.center,
                        style: context.text.labelSmall?.copyWith(color: colors.warning),
                      ),
                  ],
                ),
              ),
              SizedBox(height: spacing.md),
              AppCard(
                padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
                child: Column(
                  children: [
                    _InfoRow(
                      label: l10n.saleDetailPayment,
                      value: PaymentMethodBadge(method: sale.method),
                    ),
                    if (sale.customer case final customer?) ...[
                      const Divider(),
                      _CustomerRow(name: customer.name, onTap: () => context.push(AppRoutes.customer(customer.id))),
                    ],
                    const Divider(),
                    _InfoRow(
                      label: l10n.saleDetailItems,
                      value: Text(l10n.cartItemCount(sale.itemCount), style: context.text.titleSmall),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.xl),
              SectionHeader(title: l10n.saleDetailProducts),
              SizedBox(height: spacing.md),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final (index, item) in sale.items.indexed) ...[
                      if (index > 0) Divider(indent: spacing.md, endIndent: spacing.md),
                      _ItemRow(item: item),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.text.bodyMedium)),
          value,
        ],
      ),
    );
  }
}

/// Cliente do fiado: toque abre a conta dele.
class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: context.sizes.minTouchTarget),
        child: Row(
          children: [
            Text(AppLocalizations.of(context).saleDetailCustomer, style: context.text.bodyMedium),
            SizedBox(width: context.spacing.md),
            Expanded(
              child: Text(
                name,
                textAlign: TextAlign.end,
                style: context.text.titleSmall?.copyWith(color: context.colors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.primary),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final SaleItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quantity = quantityLabel(
      l10n,
      QuantityFormat.format(item.quantity, soldByWeight: item.soldByWeight),
      soldByWeight: item.soldByWeight,
    );
    return Padding(
      padding: EdgeInsets.all(context.spacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(l10n.saleLine(quantity, MoneyFormat.format(item.unitPriceCents)), style: context.text.bodySmall),
              ],
            ),
          ),
          SizedBox(width: context.spacing.sm),
          Text(MoneyFormat.format(item.subtotalCents), style: context.text.titleSmall),
        ],
      ),
    );
  }
}
