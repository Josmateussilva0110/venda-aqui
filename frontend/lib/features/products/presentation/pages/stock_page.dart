import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
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
  const StockPage({super.key, this.initialFilter = StockFilter.all});

  final StockFilter initialFilter;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // A chave recria o controller quando outra tela abre o estoque já filtrado
      key: ValueKey(initialFilter),
      create: (context) => StockController(context.read<ProductsRepository>(), initialFilter: initialFilter)..loadFirstPage(),
      child: const _StockView(),
    );
  }
}

class _StockView extends StatefulWidget {
  const _StockView();

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
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.extentAfter < _loadMoreExtent) context.read<StockController>().loadMore();
  }

  Future<void> _openAndReload(String location) async {
    final controller = context.read<StockController>();
    final changed = await context.push<bool>(location);
    if (changed == true) await controller.loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<StockController>();
    final spacing = context.spacing;

    return Scaffold(
      body: Column(
        children: [
          StockHeader(
            searchController: _searchController,
            onSearch: controller.search,
            filter: controller.filter,
            counts: controller.counts,
            lowStockThreshold: controller.lowStockThreshold,
            onFilter: controller.selectFilter,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadFirstPage,
              child: _StockList(
                controller: controller,
                scrollController: _scrollController,
                onOpen: (product) => _openAndReload(AppRoutes.productEdit(product.id)),
                onRestock: (product) => _openAndReload(AppRoutes.productRestock(product.id)),
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
                    onPressed: () => _openAndReload(AppRoutes.productNew),
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

class _StockList extends StatelessWidget {
  const _StockList({required this.controller, required this.scrollController, required this.onOpen, required this.onRestock});

  final StockController controller;
  final ScrollController scrollController;
  final ValueChanged<Product> onOpen;
  final ValueChanged<Product> onRestock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
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
