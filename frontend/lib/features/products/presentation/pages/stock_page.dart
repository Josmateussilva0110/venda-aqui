import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';
import '../../domain/products_repository.dart';
import '../controllers/stock_controller.dart';
import '../widgets/stock_header.dart';
import '../widgets/stock_product_card.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key, this.filter = StockFilter.all});

  /// Vem da URL; trocar o filtro na tela também passa pela URL, para o início conseguir abrir já filtrado.
  final StockFilter filter;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          StockController(context.read<ProductsRepository>(), context.read<StockChanges>(), initialFilter: filter)..loadFirstPage(),
      child: _StockView(filter: filter),
    );
  }
}

class _StockView extends StatefulWidget {
  const _StockView({required this.filter});

  final StockFilter filter;

  @override
  State<_StockView> createState() => _StockViewState();
}

class _StockViewState extends State<_StockView> {
  // Carrega a próxima página quando faltar menos que isto para o fim da lista
  static const _loadMoreExtent = 400.0;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(_StockView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A aba fica viva entre trocas: um novo filtro na URL só troca o filtro da lista já carregada.
    // Depois do frame, porque trocar o filtro notifica e aqui ainda estamos no meio do build
    if (widget.filter == oldWidget.filter) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StockController>().selectFilter(widget.filter);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = context.read<StockController>();
    // Depois de uma falha, só tenta de novo pelo botão do rodapé, não a cada arrasto
    if (controller.loadMoreFailure != null) return;
    if (_scrollController.position.extentAfter < _loadMoreExtent) controller.loadMore();
  }

  void _selectFilter(StockFilter filter) {
    context.go(AppRoutes.stockFiltered(filter == StockFilter.all ? null : filter.name));
  }

  // A lista se atualiza sozinha pelo aviso de mudança no estoque (StockController)
  void _open(String location) => context.push(location);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<StockController>();
    final spacing = context.spacing;

    return Scaffold(
      body: Column(
        children: [
          _StockHeaderSection(searchController: _searchController, onSearch: controller.search, onFilter: _selectFilter),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadFirstPage,
              child: _StockList(
                scrollController: _scrollController,
                onOpen: (product) => _open(AppRoutes.productEdit(product.id)),
                onRestock: (product) => _open(AppRoutes.productRestock(product.id)),
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: EdgeInsets.only(bottom: spacing.md),
            child: Padding(
              padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: l10n.stockAddProduct,
                    icon: Icons.add_rounded,
                    shape: AppButtonShape.rounded,
                    onPressed: () => _open(AppRoutes.productNew),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho que só reconstrói quando filtro, contagens ou limite mudam (não a cada página carregada).
class _StockHeaderSection extends StatelessWidget {
  const _StockHeaderSection({required this.searchController, required this.onSearch, required this.onFilter});

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final ValueChanged<StockFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final (filter, counts, lowStockThreshold) = context.select<StockController, (StockFilter, StockCounts, int)>(
      (controller) => (controller.filter, controller.counts, controller.lowStockThreshold),
    );
    return StockHeader(
      searchController: searchController,
      onSearch: onSearch,
      filter: filter,
      counts: counts,
      lowStockThreshold: lowStockThreshold,
      onFilter: onFilter,
    );
  }
}

class _StockList extends StatelessWidget {
  const _StockList({required this.scrollController, required this.onOpen, required this.onRestock});

  final ScrollController scrollController;
  final ValueChanged<Product> onOpen;
  final ValueChanged<Product> onRestock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<StockController>();
    final items = controller.items;

    final Widget? placeholder = switch (controller.status) {
      StockListStatus.loading => const LoadingView(),
      StockListStatus.failure => ErrorView(message: failureMessage(l10n, controller.failure!), onRetry: controller.loadFirstPage),
      StockListStatus.ready when items.isEmpty => EmptyView(message: l10n.stockEmpty),
      StockListStatus.ready => null,
    };

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
        child: placeholder != null
            ? ListView(physics: const AlwaysScrollableScrollPhysics(), children: [placeholder])
            : ListView.separated(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md + 2, spacing.lg, spacing.lg),
                itemCount: items.length + 1,
                separatorBuilder: (_, _) => SizedBox(height: spacing.sm + 2),
                itemBuilder: (context, index) {
                  if (index == items.length) return _ListFooter(controller: controller);
                  final product = items[index];
                  return StockProductCard(product: product, onOpen: () => onOpen(product), onRestock: () => onRestock(product));
                },
              ),
      ),
    );
  }
}

/// Rodapé com o estado da paginação: carregando mais, erro ou fim da lista.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.controller});

  final StockController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = controller.loadMoreFailure;
    if (failure != null) return ErrorView(message: failureMessage(l10n, failure), onRetry: controller.loadMore);
    if (controller.hasMore && !controller.isLoadingMore) {
      // Se a primeira página não encheu a tela, não haverá rolagem para pedir a próxima
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadMore());
    }
    if (controller.isLoadingMore || controller.hasMore) return const LoadingView();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.md),
      child: Text(l10n.stockEndOfList, textAlign: TextAlign.center, style: context.text.bodySmall),
    );
  }
}
