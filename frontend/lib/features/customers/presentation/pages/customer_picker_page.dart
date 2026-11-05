import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';
import '../controllers/customer_list_controller.dart';
import '../widgets/customer_tile.dart';
import '../widgets/new_customer_card.dart';

/// Venda no fiado: escolher (ou cadastrar) o cliente. Sai devolvendo o [PickedCustomer].
class CustomerPickerPage extends StatelessWidget {
  const CustomerPickerPage({super.key, required this.amountCents, this.itemCount, this.initialCustomerId});

  /// Valor que vai para a conta do cliente (só exibição; quem calcula é o servidor).
  final int amountCents;
  final int? itemCount;

  /// Cliente já escolhido antes (edição da venda).
  final String? initialCustomerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CustomerListController(context.read<CustomersRepository>())..loadFirstPage(),
      child: _PickerView(amountCents: amountCents, itemCount: itemCount, initialCustomerId: initialCustomerId),
    );
  }
}

class _PickerView extends StatefulWidget {
  const _PickerView({required this.amountCents, required this.itemCount, required this.initialCustomerId});

  final int amountCents;
  final int? itemCount;
  final String? initialCustomerId;

  @override
  State<_PickerView> createState() => _PickerViewState();
}

class _PickerViewState extends State<_PickerView> {
  static const _loadMoreExtent = 400.0;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late String? _selectedId = widget.initialCustomerId;
  Customer? _selected;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = context.read<CustomerListController>();
    if (controller.loadMoreFailure != null) return;
    if (_scrollController.position.extentAfter < _loadMoreExtent) controller.loadMore();
  }

  void _select(Customer customer) => setState(() {
    _selectedId = customer.id;
    _selected = customer;
  });

  void _confirm(Customer? selected) {
    if (selected == null) {
      showAppToast(context, AppLocalizations.of(context).creditPickerSelect, tone: ToastTone.error);
      return;
    }
    context.pop<PickedCustomer>((id: selected.id, name: selected.name));
  }

  Future<ValidationFailure?> _create(CustomerInput input) async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<CustomerListController>();
    try {
      final customer = await controller.create(input);
      if (!mounted) return null;
      setState(() => _isAdding = false);
      _select(customer);
      showAppToast(context, l10n.customerSaved);
      return null;
    } on ValidationFailure catch (failure) {
      return failure;
    } on AppFailure catch (failure) {
      if (mounted) showAppToast(context, failureMessage(l10n, failure), tone: ToastTone.error);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<CustomerListController>();
    final customers = controller.items;
    // O cliente escolhido pode ter saído da lista ao trocar a busca: guarda o objeto, não só a posição
    final selected = _selected ?? customers.where((customer) => customer.id == _selectedId).firstOrNull;

    final Widget? placeholder = switch (controller.status) {
      CustomerListStatus.loading => const LoadingView(),
      CustomerListStatus.failure => ErrorView(message: failureMessage(l10n, controller.failure!), onRetry: controller.loadFirstPage),
      CustomerListStatus.ready when customers.isEmpty => EmptyView(message: l10n.creditPickerEmpty),
      CustomerListStatus.ready => null,
    };
    final header = [
      _AmountCard(amountCents: widget.amountCents, itemCount: widget.itemCount),
      Padding(
        padding: EdgeInsets.only(top: spacing.xl, bottom: spacing.md),
        child: Text(l10n.creditPickerQuestion, style: context.text.titleMedium),
      ),
      SearchField(controller: _searchController, hint: l10n.customerSearchHint, onChanged: controller.setSearch),
      Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.md),
        child: _isAdding
            ? NewCustomerCard(
                // Busca com letras vira o nome sugerido; com números, não
                initialName: controller.search.replaceAll(RegExp(r'\d'), '').trim(),
                isSaving: controller.isCreating,
                onSubmit: _create,
                onCancel: () => setState(() => _isAdding = false),
              )
            : AppButton(
                label: l10n.customerNewButton,
                icon: Icons.person_add_alt_1_rounded,
                variant: AppButtonVariant.outlined,
                compact: true,
                onPressed: () => setState(() => _isAdding = true),
              ),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.creditPickerTitle, onBack: () => context.pop(), buttonBackground: context.colors.surface),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.xl),
                    itemCount: header.length + (placeholder != null ? 1 : customers.length + 1),
                    itemBuilder: (context, index) {
                      if (index < header.length) return header[index];
                      if (placeholder != null) return placeholder;
                      final position = index - header.length;
                      if (position == customers.length) {
                        return PaginationFooter(
                          hasMore: controller.hasMore,
                          isLoadingMore: controller.isLoadingMore,
                          failure: controller.loadMoreFailure,
                          onLoadMore: controller.loadMore,
                          onRetry: controller.retryLoadMore,
                        );
                      }
                      final customer = customers[position];
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing.sm),
                        child: CustomerTile(customer: customer, selected: customer.id == selected?.id, onTap: () => _select(customer)),
                      );
                    },
                  ),
                ),
              ),
            ),
            _ConfirmBar(selected: selected, onConfirm: () => _confirm(selected)),
          ],
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.amountCents, required this.itemCount});

  final int amountCents;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final count = itemCount;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.warningSoft, borderRadius: BorderRadius.circular(context.radius.xxl)),
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.creditPickerAmount, style: context.text.bodyMedium?.copyWith(color: colors.warning)),
                  if (count != null) Text(l10n.cartItemCount(count), style: context.text.bodySmall?.copyWith(color: colors.warning)),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(MoneyFormat.format(amountCents), style: context.text.headlineMedium?.copyWith(color: colors.warning)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({required this.selected, required this.onConfirm});

  final Customer? selected;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final customer = selected;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.xl, spacing.sm, spacing.xl, spacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: customer == null ? l10n.creditPickerSelect : l10n.creditPickerConfirm(customer.name),
              isActive: customer != null,
              onPressed: onConfirm,
            ),
            SizedBox(height: spacing.xs),
            Text(l10n.creditPickerHint, textAlign: TextAlign.center, style: context.text.bodySmall),
          ],
        ),
      ),
    );
  }
}
