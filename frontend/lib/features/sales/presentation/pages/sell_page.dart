import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';
import '../../domain/sales_repository.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/sale_cart_controller.dart';
import '../widgets/cart_feedback.dart';
import '../widgets/catalog_tile.dart';
import 'weight_page.dart';

/// Nova venda: grade de produtos e barra do carrinho.
class SellPage extends StatelessWidget {
  const SellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CatalogController(context.read<SalesRepository>())..loadFirstPage(),
      child: const _SellView(),
    );
  }
}

class _SellView extends StatefulWidget {
  const _SellView();

  @override
  State<_SellView> createState() => _SellViewState();
}

class _SellViewState extends State<_SellView> {
  // Carrega a próxima página quando faltar menos que isto para o fim da grade
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
    if (_scrollController.position.extentAfter < _loadMoreExtent) context.read<CatalogController>().loadMore();
  }

  void _add(CatalogProduct product) {
    final issue = context.read<SaleCartController>().addOne(product);
    if (issue != null) showCartIssue(context, issue, product);
  }

  void _weigh(CatalogProduct product) {
    if (product.isOutOfStock) return _add(product);
    context.push(AppRoutes.sellWeight, extra: WeightRequest(product: product));
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<CatalogController>();
    return Scaffold(
      body: Column(
        children: [
          _SellHeader(searchController: _searchController, onSearch: catalog.search),
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: catalog.loadFirstPage,
                  child: _CatalogGrid(scrollController: _scrollController, onAdd: _add, onWeigh: _weigh),
                ),
                const Positioned(left: 0, right: 0, bottom: 0, child: _CartBar()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SellHeader extends StatelessWidget {
  const _SellHeader({required this.searchController, required this.onSearch});

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final hasItems = context.select<SaleCartController, bool>((cart) => !cart.isEmpty);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(context.radius.xxxl)),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(spacing.xl, spacing.lg, spacing.xl, spacing.md + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(header: true, child: Text(l10n.sellTitle, style: context.text.headlineSmall)),
                            SizedBox(height: spacing.xxs),
                            Text(l10n.sellHint, style: context.text.bodySmall),
                          ],
                        ),
                      ),
                      if (hasItems)
                        TextButton(
                          onPressed: context.read<SaleCartController>().clear,
                          style: TextButton.styleFrom(
                            backgroundColor: colors.surfaceMuted,
                            foregroundColor: colors.inkSoft,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(l10n.sellClear, style: context.text.labelMedium?.copyWith(color: colors.inkSoft)),
                        ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  SearchField(controller: searchController, hint: l10n.sellSearchHint, onChanged: onSearch),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grade em linhas (uma linha por item da lista), para cada linha ter a altura do conteúdo
/// mesmo com a fonte do sistema aumentada, sem perder a construção preguiçosa.
class _CatalogGrid extends StatelessWidget {
  const _CatalogGrid({required this.scrollController, required this.onAdd, required this.onWeigh});

  final ScrollController scrollController;
  final ValueChanged<CatalogProduct> onAdd;
  final ValueChanged<CatalogProduct> onWeigh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final catalog = context.watch<CatalogController>();
    final items = catalog.items;

    final Widget? placeholder = switch (catalog.status) {
      CatalogStatus.loading => const LoadingView(),
      CatalogStatus.failure => ErrorView(message: failureMessage(l10n, catalog.failure!), onRetry: catalog.loadFirstPage),
      CatalogStatus.ready when items.isEmpty => EmptyView(message: l10n.sellEmpty),
      CatalogStatus.ready => null,
    };
    if (placeholder != null) return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [placeholder]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, AppBreakpoints.listMaxWidth) - spacing.lg * 2;
        final columns = math.max(2, (width / context.sizes.catalogTileMinWidth).floor());
        final rows = (items.length / columns).ceil();
        return ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          // Espaço no fim para a barra do carrinho não cobrir a última linha
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md + 2, spacing.lg, context.sizes.buttonHeight * 2 + spacing.xl),
          itemCount: rows + 1,
          itemBuilder: (context, row) {
            if (row == rows) return _GridFooter(catalog: catalog);
            final start = row * columns;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
                child: Padding(
                  padding: EdgeInsets.only(bottom: spacing.md),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var column = 0; column < columns; column++) ...[
                          if (column > 0) SizedBox(width: spacing.md),
                          Expanded(
                            child: start + column < items.length
                                ? _CartAwareTile(product: items[start + column], onAdd: onAdd, onWeigh: onWeigh)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Cada card ouve só a própria quantidade no carrinho: somar um produto não reconstrói a grade.
class _CartAwareTile extends StatelessWidget {
  const _CartAwareTile({required this.product, required this.onAdd, required this.onWeigh});

  final CatalogProduct product;
  final ValueChanged<CatalogProduct> onAdd;
  final ValueChanged<CatalogProduct> onWeigh;

  @override
  Widget build(BuildContext context) {
    final quantity = context.select<SaleCartController, double>((cart) => cart.quantityOf(product.id));
    return CatalogTile(
      product: product,
      cartQuantity: quantity,
      onTap: () => onAdd(product),
      onLongPress: product.soldByWeight ? () => onWeigh(product) : null,
    );
  }
}

class _GridFooter extends StatelessWidget {
  const _GridFooter({required this.catalog});

  final CatalogController catalog;

  @override
  Widget build(BuildContext context) {
    final failure = catalog.loadMoreFailure;
    if (failure != null) return ErrorView(message: failureMessage(AppLocalizations.of(context), failure), onRetry: catalog.retryLoadMore);
    if (catalog.hasMore && !catalog.isLoadingMore) {
      // Se a primeira página não encheu a tela, não haverá rolagem para pedir a próxima
      WidgetsBinding.instance.addPostFrameCallback((_) => catalog.loadMore());
    }
    return catalog.hasMore ? const LoadingView() : const SizedBox.shrink();
  }
}

/// Barra escura com itens, total e "Ver resumo"; só aparece com algo no carrinho.
class _CartBar extends StatelessWidget {
  const _CartBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final (count, total) = context.select<SaleCartController, (int, int)>((cart) => (cart.itemCount, cart.totalCents));
    if (count == 0) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      minimum: EdgeInsets.all(spacing.lg),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
          child: Material(
            color: colors.chipActive,
            borderRadius: BorderRadius.circular(context.radius.xxl),
            elevation: 6,
            shadowColor: colors.shadow,
            child: InkWell(
              onTap: () => context.push(AppRoutes.sellSummary),
              borderRadius: BorderRadius.circular(context.radius.xxl),
              child: Padding(
                padding: EdgeInsets.fromLTRB(spacing.md + 2, spacing.sm + 2, spacing.sm + 2, spacing.sm + 2),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(context.radius.pill)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing.sm + 2, vertical: spacing.xs + 2),
                        child: Text(l10n.cartItemCount(count), style: context.text.labelMedium?.copyWith(color: colors.onPrimary)),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    // Em telas estreitas o total encolhe e o botão quebra o texto, em vez de estourar a linha
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(MoneyFormat.format(total), style: context.text.titleLarge?.copyWith(color: colors.onChipActive)),
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Flexible(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: colors.onChipActive, borderRadius: BorderRadius.circular(context.radius.lg)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm + 2),
                          child: Text(
                            l10n.sellViewSummary,
                            textAlign: TextAlign.center,
                            style: context.text.titleSmall?.copyWith(color: colors.chipActive),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
