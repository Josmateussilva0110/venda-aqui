import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui/app/app.dart';
import 'package:vendaqui/app/dependencies.dart';
import 'package:vendaqui/core/routing/app_routes.dart';
import 'package:vendaqui/core/stock/stock_changes.dart';
import 'package:vendaqui/features/auth/presentation/controllers/session_controller.dart';
import 'package:vendaqui/features/customers/domain/customer.dart';

import '../support/fakes.dart';

/// Abre cada tela principal em vários tamanhos e falha com qualquer overflow.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  const viewports = <String, Size>{
    'celular pequeno': Size(320, 568),
    'celular comum': Size(390, 844),
    'celular em paisagem': Size(844, 390),
    'tablet em paisagem': Size(1024, 768),
  };
  const textScales = [1.0, 1.3];

  const signedOutRoutes = [AppRoutes.welcome, AppRoutes.login, AppRoutes.register, AppRoutes.recoverPin];
  final signedInRoutes = [
    AppRoutes.home,
    AppRoutes.stock,
    AppRoutes.productNew,
    AppRoutes.productEdit('p1'),
    AppRoutes.productRestock('p2'),
    AppRoutes.settings,
    AppRoutes.sell,
    AppRoutes.sellSummary,
    AppRoutes.sellPayment,
    AppRoutes.salesHistory,
    AppRoutes.reports,
    AppRoutes.customers,
    AppRoutes.customer(testCustomer.id),
  ];

  Future<void> pumpApp(WidgetTester tester, {required bool signedIn}) async {
    final auth = FakeAuthRepository(signedIn: signedIn);
    final sales = FakeSalesRepository();
    final dependencies = AppDependencies(
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
      customersRepository: FakeCustomersRepository(customers: [testCustomer])
        ..statements[testCustomer.id] = [
          StatementEntry(kind: StatementEntryKind.sale, id: 's1', amountCents: 12345, createdAt: DateTime(2026, 10, 30, 9)),
          StatementEntry(
            kind: StatementEntryKind.payment,
            id: 'p1',
            amountCents: 2000,
            createdAt: DateTime(2026, 10, 30, 10),
            settlementMethod: SettlementMethod.pix,
          ),
        ],
    );
    // Carrinho com um item de cada tipo: a barra do carrinho, o resumo e o pagamento aparecem preenchidos
    for (final product in sales.catalogItems.where((product) => !product.isOutOfStock)) {
      dependencies.saleCart.addOne(product);
    }
    await tester.pumpWidget(VendaquiApp(key: UniqueKey(), dependencies: dependencies));
    await tester.pumpAndSettle();
  }

  Future<void> visit(WidgetTester tester, String location, {Object? extra}) async {
    final router = GoRouter.of(tester.element(find.byType(Navigator).first))..go(location, extra: extra);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'erro de layout em $location');
    // Garante que a tela abriu de fato (e não foi redirecionada para outra)
    expect(router.routerDelegate.currentConfiguration.uri.path, location);
  }

  for (final MapEntry(key: label, value: size) in viewports.entries) {
    for (final scale in textScales) {
      testWidgets('telas sem overflow: $label, fonte ${scale}x', (tester) async {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpApp(tester, signedIn: false);
        for (final route in signedOutRoutes) {
          await visit(tester, route);
        }

        await pumpApp(tester, signedIn: true);
        for (final route in signedInRoutes) {
          await visit(tester, route);
        }
        const CustomerPickerRequest pickerRequest = (amountCents: 4590, itemCount: 3, initialCustomerId: null);
        await visit(tester, AppRoutes.customerPicker, extra: pickerRequest);
      });
    }
  }
}
