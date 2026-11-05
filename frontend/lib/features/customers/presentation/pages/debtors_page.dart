import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';
import '../controllers/customer_list_controller.dart';
import '../widgets/customer_tile.dart';

/// Fiado: quanto há para receber e quem deve, em ordem alfabética.
class DebtorsPage extends StatelessWidget {
  const DebtorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          CustomerListController(context.read<CustomersRepository>(), initialFilter: CustomerBalanceFilter.owing)..loadFirstPage(),
      child: const _DebtorsView(),
    );
  }
}

class _DebtorsView extends StatefulWidget {
  const _DebtorsView();

  @override
  State<_DebtorsView> createState() => _DebtorsViewState();
}

class _DebtorsViewState extends State<_DebtorsView> {
  static const _loadMoreExtent = 400.0;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Recebeu pagamento em alguma conta: o início confere o total do fiado ao voltar
  bool _changed = false;

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

  // Só busca de novo se recebeu pagamento na conta, sem limpar a tela
  Future<void> _open(Customer customer) async {
    final controller = context.read<CustomerListController>();
    final changed = await context.push<bool>(AppRoutes.customer(customer.id));
    if (changed != true) return;
    _changed = true;
    await controller.loadFirstPage(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<CustomerListController>();
    final customers = controller.items;

    final Widget? placeholder = switch (controller.status) {
      CustomerListStatus.loading => const LoadingView(),
      CustomerListStatus.failure => ErrorView(message: failureMessage(l10n, controller.failure!), onRetry: controller.loadFirstPage),
      CustomerListStatus.ready when customers.isEmpty => EmptyView(
        message: controller.filter == CustomerBalanceFilter.owing && controller.search.isEmpty ? l10n.debtorsEmptyOwing : l10n.debtorsEmpty,
      ),
      CustomerListStatus.ready => null,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(_changed);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenHeader(title: l10n.debtorsTitle, onBack: () => context.pop(_changed), buttonBackground: context.colors.surface),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
                    child: RefreshIndicator(
                      onRefresh: controller.loadFirstPage,
                      // O resumo e os filtros rolam junto: em celular deitado não sobraria espaço para a lista
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xl),
                        itemCount: 1 + (placeholder != null ? 1 : customers.length + 1),
                        itemBuilder: (context, index) {
                          if (index == 0) return _DebtorsHeader(searchController: _searchController);
                          if (placeholder != null) return placeholder;
                          if (index == customers.length + 1) {
                            return PaginationFooter(
                              hasMore: controller.hasMore,
                              isLoadingMore: controller.isLoadingMore,
                              failure: controller.loadMoreFailure,
                              onLoadMore: controller.loadMore,
                              onRetry: controller.retryLoadMore,
                            );
                          }
                          final customer = customers[index - 1];
                          return Padding(
                            padding: EdgeInsets.only(bottom: spacing.sm),
                            child: CustomerTile(customer: customer, showAmount: true, onTap: () => _open(customer)),
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

/// Total a receber, busca e filtro. Reconstrói só quando o resumo ou o filtro muda.
class _DebtorsHeader extends StatelessWidget {
  const _DebtorsHeader({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final controller = context.read<CustomerListController>();
    final (summary, filter) = context.select<CustomerListController, (CreditSummary?, CustomerBalanceFilter)>(
      (list) => (list.summary, list.filter),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.debtorsSubtitle, style: context.text.bodyMedium),
          SizedBox(height: spacing.md),
          DecoratedBox(
            decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(context.radius.xxl)),
            child: Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.debtorsTotal, style: context.text.bodyMedium?.copyWith(color: colors.onPrimaryMuted)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      summary == null ? '—' : MoneyFormat.format(summary.owedCents),
                      style: context.text.displayMedium?.copyWith(color: colors.onPrimary),
                    ),
                  ),
                  if (summary != null)
                    Text(l10n.debtorsOwingCount(summary.owingCount), style: context.text.bodySmall?.copyWith(color: colors.onPrimaryMuted)),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          SearchField(controller: searchController, hint: l10n.debtorsSearchHint, onChanged: controller.setSearch),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              FilterPill(
                label: l10n.debtorsFilterOwing,
                selected: filter == CustomerBalanceFilter.owing,
                onTap: () => controller.selectFilter(CustomerBalanceFilter.owing),
              ),
              FilterPill(
                label: l10n.debtorsFilterAll,
                selected: filter == CustomerBalanceFilter.all,
                onTap: () => controller.selectFilter(CustomerBalanceFilter.all),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
