import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui/app/app.dart';
import 'package:vendaqui/app/dependencies.dart';
import 'package:vendaqui/core/network/app_failure.dart';
import 'package:vendaqui/core/network/cancel_signal.dart';
import 'package:vendaqui/core/routing/app_routes.dart';
import 'package:vendaqui/core/stock/stock_changes.dart';
import 'package:vendaqui/core/stock/stock_level.dart';
import 'package:vendaqui/features/dashboard/domain/stock_overview.dart';
import 'package:vendaqui/features/products/domain/product.dart';
import 'package:vendaqui/features/auth/presentation/controllers/session_controller.dart';

import '../support/fakes.dart';

class _CountingProducts extends FakeProductsRepository {
  _CountingProducts({this.failLoadMore = false});

  final bool failLoadMore;
  int listCalls = 0;
  final filters = <StockFilter>[];

  static final _catalog = [
    for (var i = 0; i < 70; i++)
      Product(
        id: 'p$i',
        name: 'Produto $i',
        photoUrl: null,
        salePriceCents: 100,
        costPriceCents: 50,
        quantity: 10,
        soldByWeight: false,
        stockLevel: StockLevel.ok,
      ),
  ];

  @override
  Future<ProductPage> list({
    required String search,
    required StockFilter filter,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  }) async {
    listCalls++;
    filters.add(filter);
    if (failLoadMore && offset > 0) throw const NetworkFailure();
    return ProductPage(
      items: _catalog.skip(offset).take(limit).toList(),
      total: _catalog.length,
      stockCounts: offset == 0 ? StockCounts(all: _catalog.length, low: 0, out: 0) : null,
      lowStockThreshold: 5,
    );
  }
}

class _CountingDashboard extends FakeDashboardRepository {
  int calls = 0;

  @override
  Future<StockOverview> stockOverview({required int alertLimit}) {
    calls++;
    return super.stockOverview(alertLimit: alertLimit);
  }
}

/// Garantias de desempenho da navegação: trocar de aba e rolar não disparam requisições à toa.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<void> pumpApp(WidgetTester tester, _CountingProducts products, _CountingDashboard dashboard) async {
    final auth = FakeAuthRepository(signedIn: true);
    final dependencies = AppDependencies(
      authRepository: auth,
      productsRepository: products,
      dashboardRepository: dashboard,
      photoPicker: FakePhotoPicker(),
      sessionController: SessionController(auth),
      stockChanges: StockChanges(),
      themeController: lightThemeController(),
    );
    await tester.pumpWidget(VendaquiApp(dependencies: dependencies));
    await tester.pumpAndSettle();
  }

  testWidgets('trocar de aba não recarrega início nem estoque', (tester) async {
    final products = _CountingProducts();
    final dashboard = _CountingDashboard();
    await pumpApp(tester, products, dashboard);

    for (var round = 0; round < 3; round++) {
      await tester.tap(find.text('Estoque'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
    }

    expect(dashboard.calls, 1);
    expect(products.listCalls, 1);
  });

  testWidgets('filtro vindo da URL troca o filtro da lista aberta, com um pedido só', (tester) async {
    final products = _CountingProducts();
    await pumpApp(tester, products, _CountingDashboard());
    await tester.tap(find.text('Estoque'));
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byType(Navigator).first)).go(AppRoutes.stockFiltered('out'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(products.filters, [StockFilter.all, StockFilter.out]);
  });

  testWidgets('sair da conta pelas configurações volta para as boas-vindas', (tester) async {
    await pumpApp(tester, _CountingProducts(), _CountingDashboard());

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    final router = GoRouter.of(tester.element(find.byType(Navigator).first));
    expect(router.routerDelegate.currentConfiguration.uri.path, AppRoutes.welcome);
    expect(find.text('Você saiu. Entre com seu PIN.'), findsOneWidget);
  });

  testWidgets('depois de falhar ao carregar mais, rolar não tenta de novo', (tester) async {
    final products = _CountingProducts(failLoadMore: true);
    await pumpApp(tester, products, _CountingDashboard());
    await tester.tap(find.text('Estoque'));
    await tester.pumpAndSettle();

    for (var drag = 0; drag < 10; drag++) {
      await tester.fling(find.byType(Scrollable).last, const Offset(0, -2000), 3000);
      await tester.pumpAndSettle();
    }

    // Primeira página + uma única tentativa da segunda
    expect(products.listCalls, 2);
  });
}
