import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui/app/app.dart';
import 'package:vendaqui/app/dependencies.dart';
import 'package:vendaqui/core/routing/app_routes.dart';
import 'package:vendaqui/core/stock/stock_changes.dart';
import 'package:vendaqui/features/auth/presentation/controllers/session_controller.dart';
import 'package:vendaqui/features/sales/domain/sale.dart';
import 'package:vendaqui/features/sales/presentation/widgets/catalog_tile.dart';

import '../../support/fakes.dart';

const _rice = CatalogProduct(id: 'rice', name: 'Arroz', salePriceCents: 2500, quantity: 5, soldByWeight: false);
const _tomato = CatalogProduct(id: 'tomato', name: 'Tomate', salePriceCents: 800, quantity: 10, soldByWeight: true);

/// Venda inteira pela interface: grade, peso, resumo, pagamento, histórico e edição.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('vende, aparece no histórico e pode ser editada', (tester) async {
    final sales = FakeSalesRepository(catalog: const [_rice, _tomato]);
    final auth = FakeAuthRepository(signedIn: true);
    await tester.pumpWidget(
      VendaquiApp(
        dependencies: AppDependencies(
          authRepository: auth,
          productsRepository: FakeProductsRepository(),
          dashboardRepository: FakeDashboardRepository(),
          photoPicker: FakePhotoPicker(),
          sessionController: SessionController(auth),
          stockChanges: StockChanges(),
          themeController: lightThemeController(),
          salesRepository: sales,
          saleCart: saleCartFor(sales),
          reportsRepository: FakeReportsRepository(),
          customersRepository: FakeCustomersRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Grade: dois toques no arroz, segurar o tomate para pesar
    await tester.tap(find.text('Vender'));
    await tester.pumpAndSettle();
    final riceTile = find.widgetWithText(CatalogTile, 'Arroz');
    await tester.tap(riceTile);
    await tester.tap(riceTile);
    await tester.pump();
    await tester.longPress(find.widgetWithText(CatalogTile, 'Tomate'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '0,5');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    expect(find.text('3 itens'), findsOneWidget);

    // Resumo e pagamento
    await tester.tap(find.text('Ver resumo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finalizar venda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PIX'));
    await tester.pumpAndSettle();
    expect(find.text('Venda registrada!'), findsOneWidget);

    final registered = sales.sales.single;
    expect(registered.method, PaymentMethod.pix);
    expect(registered.totalCents, 2 * 2500 + 400);

    // Histórico → detalhe → editar (tira o tomate e troca para dinheiro)
    GoRouter.of(tester.element(find.byType(Navigator).first)).go(AppRoutes.salesHistory);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arroz, Tomate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar venda'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remover').last);
    await tester.tap(find.text('Dinheiro'));
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final edited = await sales.get(registered.id);
    expect(edited.method, PaymentMethod.cash);
    expect(edited.items.map((item) => item.productId), ['rice']);
    expect(edited.editedAt, isNotNull);
    expect(find.text('Detalhe da venda'), findsOneWidget);
  });

  testWidgets('voltar do detalhe sem editar não busca o histórico de novo', (tester) async {
    final sales = FakeSalesRepository(catalog: const [_rice]);
    final cart = saleCartFor(sales);
    final auth = FakeAuthRepository(signedIn: true);
    for (var i = 0; i < 3; i++) {
      cart.addOne(_rice);
      await cart.checkout(PaymentMethod.cash);
    }
    await tester.pumpWidget(
      VendaquiApp(
        dependencies: AppDependencies(
          authRepository: auth,
          productsRepository: FakeProductsRepository(),
          dashboardRepository: FakeDashboardRepository(),
          photoPicker: FakePhotoPicker(),
          sessionController: SessionController(auth),
          stockChanges: StockChanges(),
          themeController: lightThemeController(),
          salesRepository: sales,
          saleCart: cart,
          reportsRepository: FakeReportsRepository(),
          customersRepository: FakeCustomersRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(GoRouter.of(tester.element(find.byType(Navigator).first)).push(AppRoutes.salesHistory));
    await tester.pumpAndSettle();
    final callsAfterOpening = sales.historyCalls;

    await tester.tap(find.text('Arroz').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Histórico de vendas'), findsOneWidget);
    expect(sales.historyCalls, callsAfterOpening);
  });
}
