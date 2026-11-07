import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';
import '../controllers/sale_cart_controller.dart';
import '../widgets/payment_method_style.dart';

/// Pagamento: um toque na forma de pagamento registra a venda. O fiado antes pede o cliente.
class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  Future<void> _pay(BuildContext context, PaymentMethod method) async {
    final cart = context.read<SaleCartController>();
    SaleCustomer? customer;
    if (method == PaymentMethod.credit) {
      final CustomerPickerRequest request = (amountCents: cart.totalCents, itemCount: cart.itemCount, initialCustomerId: null);
      final picked = await context.push<PickedCustomer>(AppRoutes.customerPicker, extra: request);
      if (picked == null || !context.mounted) return;
      customer = SaleCustomer(id: picked.id, name: picked.name);
    }
    final l10n = AppLocalizations.of(context);
    final sale = await cart.checkout(method, customer: customer);
    if (!context.mounted) return;
    final failure = cart.checkoutFailure;
    if (sale == null) {
      if (failure != null) showAppToast(context, failureMessage(l10n, failure), tone: ToastTone.error);
      return;
    }
    // Troca a pilha: voltar da confirmação não pode reabrir o pagamento de uma venda já feita
    context.go(AppRoutes.sellDone, extra: sale);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final cart = context.watch<SaleCartController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.paymentTitle, onBack: () => context.pop(), buttonBackground: colors.surface),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.xl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TotalCard(totalCents: cart.totalCents, itemCount: cart.itemCount),
                        SizedBox(height: spacing.xl),
                        Text(l10n.paymentQuestion, style: context.text.titleMedium),
                        SizedBox(height: spacing.md),
                        for (final method in PaymentMethod.values) ...[
                          _PaymentOption(method: method, enabled: !cart.isCheckingOut && !cart.isEmpty, onTap: () => _pay(context, method)),
                          SizedBox(height: spacing.sm + 2),
                        ],
                        if (cart.isCheckingOut) const Center(child: CircularProgressIndicator()),
                        SizedBox(height: spacing.sm),
                        Text(l10n.paymentHint, textAlign: TextAlign.center, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.totalCents, required this.itemCount});

  final int totalCents;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(context.radius.xxl)),
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          children: [
            Text(l10n.paymentTotal, style: context.text.bodyMedium?.copyWith(color: colors.onPrimaryMuted)),
            SizedBox(height: spacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(MoneyFormat.format(totalCents), style: context.text.displayMedium?.copyWith(color: colors.onPrimary)),
            ),
            SizedBox(height: spacing.xs),
            Text(l10n.cartItemCount(itemCount), style: context.text.bodySmall?.copyWith(color: colors.onPrimaryMuted)),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({required this.method, required this.enabled, required this.onTap});

  final PaymentMethod method;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final palette = method.colors(context);
    return AppCard(
      onTap: enabled ? onTap : null,
      padding: EdgeInsets.all(spacing.md),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(context.radius.lg)),
            child: Padding(
              padding: EdgeInsets.all(spacing.sm + 2),
              child: Icon(method.icon, color: palette.foreground, size: context.sizes.iconLarge),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method.label(l10n), style: context.text.titleMedium),
                Text(method.detail(l10n), style: context.text.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.colors.subtle),
        ],
      ),
    );
  }
}
