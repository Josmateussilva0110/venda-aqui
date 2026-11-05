import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';
import '../controllers/customer_account_controller.dart';
import '../widgets/receive_payment_panel.dart';
import '../widgets/statement_entry_tile.dart';

/// Conta do cliente: quanto deve, receber o fiado e as movimentações.
class CustomerAccountPage extends StatelessWidget {
  const CustomerAccountPage({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CustomerAccountController(context.read<CustomersRepository>(), customerId)..load(),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatefulWidget {
  const _AccountView();

  @override
  State<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<_AccountView> {
  static const _loadMoreExtent = 400.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = context.read<CustomerAccountController>();
    if (controller.loadMoreFailure != null) return;
    if (_scrollController.position.extentAfter < _loadMoreExtent) controller.loadMore();
  }

  // Editar a venda pode mudar o saldo: volta e confere com o servidor
  Future<void> _openSale(String saleId) async {
    final controller = context.read<CustomerAccountController>();
    final edited = await context.push<bool>(AppRoutes.sale(saleId));
    if (edited == true) await controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<CustomerAccountController>();
    final customer = controller.customer;
    final entries = controller.entries;
    final dateFormat = DateFormat.MMMd(Localizations.localeOf(context).toString()).add_Hm();

    final Widget? placeholder = switch ((customer, controller.failure)) {
      (null, final AppFailure failure) => ErrorView(message: failureMessage(l10n, failure), onRetry: controller.load),
      (null, null) => const LoadingView(),
      _ => null,
    };
    final header = customer == null
        ? const <Widget>[]
        : [
            _BalanceCard(customer: customer),
            SizedBox(height: spacing.xl),
            SectionHeader(title: l10n.statementTitle),
            SizedBox(height: spacing.md),
            if (entries.isEmpty) EmptyView(message: l10n.statementEmpty),
          ];

    // Sai devolvendo se houve pagamento, para a lista de devedores só buscar de novo quando precisa
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(controller.changed);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenHeader(
                title: l10n.accountTitle,
                onBack: () => context.pop(controller.changed),
                buttonBackground: context.colors.surface,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                    child:
                        placeholder ??
                        RefreshIndicator(
                          onRefresh: controller.load,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.xl),
                            itemCount: header.length + entries.length + 1,
                            itemBuilder: (context, index) {
                              if (index < header.length) return header[index];
                              final position = index - header.length;
                              if (position == entries.length) {
                                return PaginationFooter(
                                  hasMore: controller.hasMore,
                                  isLoadingMore: controller.isLoadingMore,
                                  failure: controller.loadMoreFailure,
                                  onLoadMore: controller.loadMore,
                                  onRetry: controller.retryLoadMore,
                                );
                              }
                              final entry = entries[position];
                              return _StatementCell(
                                isFirst: position == 0,
                                isLast: position == entries.length - 1,
                                child: StatementEntryTile(
                                  entry: entry,
                                  dateFormat: dateFormat,
                                  onTap: entry.kind == StatementEntryKind.sale ? () => _openSale(entry.id) : null,
                                ),
                              );
                            },
                          ),
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

/// Linhas do extrato desenhadas como um cartão só, sem montar todas de uma vez.
class _StatementCell extends StatelessWidget {
  const _StatementCell({required this.isFirst, required this.isLast, required this.child});

  final bool isFirst;
  final bool isLast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = Radius.circular(context.radius.xxl);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.vertical(top: isFirst ? radius : Radius.zero, bottom: isLast ? radius : Radius.zero),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: isFirst ? null : Border(top: BorderSide(color: colors.divider)),
        ),
        child: child,
      ),
    );
  }
}

/// Nome, telefone, dívida e o recebimento (parte ou tudo).
class _BalanceCard extends StatefulWidget {
  const _BalanceCard({required this.customer});

  final Customer customer;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  // Nulo: painel fechado. Zero: "Receber parte" (campo vazio). Positivo: "Receber tudo".
  int? _panelAmount;

  Future<void> _receive(int amountCents, SettlementMethod method) async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<CustomerAccountController>();
    try {
      await controller.registerPayment(amountCents: amountCents, method: method);
      if (!mounted) return;
      setState(() => _panelAmount = null);
      showAppToast(context, l10n.receiveDone);
    } on AppFailure catch (failure) {
      if (mounted) showAppToast(context, failureMessage(l10n, failure), tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final customer = widget.customer;
    final controller = context.read<CustomerAccountController>();
    final isPaying = context.select<CustomerAccountController, bool>((account) => account.isPaying);
    final panelAmount = _panelAmount;

    return AppCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProductAvatar(name: customer.name, colorSeed: customer.id, size: context.sizes.avatar),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: context.text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(PhoneFormat.fromE164(customer.phone), style: context.text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Text(l10n.accountBalance, style: context.text.bodyMedium),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              MoneyFormat.format(customer.balanceCents),
              style: context.text.displayMedium?.copyWith(color: customer.owes ? colors.danger : colors.successStrong),
            ),
          ),
          if (!customer.owes) Text(l10n.accountClear, style: context.text.bodySmall),
          if (customer.owes) ...[
            SizedBox(height: spacing.md),
            if (panelAmount == null)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.accountReceivePart,
                      variant: AppButtonVariant.outlined,
                      compact: true,
                      onPressed: () => setState(() => _panelAmount = 0),
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: AppButton(
                      label: l10n.accountReceiveAll,
                      compact: true,
                      onPressed: () => setState(() => _panelAmount = customer.balanceCents),
                    ),
                  ),
                ],
              )
            else
              ReceivePaymentPanel(
                // Trocar entre parte e tudo recria o painel com o valor certo
                key: ValueKey(panelAmount),
                balanceCents: customer.balanceCents,
                initialAmountCents: panelAmount == 0 ? null : panelAmount,
                isSaving: isPaying,
                validate: controller.validatePayment,
                onSubmit: _receive,
                onCancel: () => setState(() => _panelAmount = null),
              ),
          ],
        ],
      ),
    );
  }
}
