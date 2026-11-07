import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui/app/app.dart';
import 'package:vendaqui/app/dependencies.dart';
import 'package:vendaqui/core/stock/stock_changes.dart';
import 'package:vendaqui/features/auth/presentation/controllers/session_controller.dart';
import 'package:vendaqui/features/sales/data/sale_dto.dart';
import 'package:vendaqui/features/sales/domain/sale.dart';
import 'package:vendaqui/features/sales/presentation/widgets/catalog_tile.dart';

import '../../support/fakes.dart';

const _rice = CatalogProduct(id: 'rice', name: 'Arroz', salePriceCents: 2500, quantity: 5, soldByWeight: false);

/// Venda fiado: sem cliente não registra; o cliente escolhido (ou cadastrado na hora) vai para a venda.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('cadastra o cliente na hora e anota a venda na conta dele', (tester) async {
    final sales = FakeSalesRepository(catalog: const [_rice]);
    final customers = FakeCustomersRepository();
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
          customersRepository: customers,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vender'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CatalogTile, 'Arroz'));
    await tester.pump();
    await tester.tap(find.text('Ver resumo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finalizar venda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fiado'));
    await tester.pumpAndSettle();

    // Confirmar sem cliente não registra nada
    await tester.tap(find.text('Selecione um cliente'));
    await tester.pumpAndSettle();
    expect(sales.sales, isEmpty);

    await tester.tap(find.text('Cadastrar novo cliente'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Ex.: Dona Maria'), 'Dona Maria');
    await tester.enterText(find.widgetWithText(TextField, '(00) 00000-0000'), '86999990000');
    await tester.ensureVisible(find.text('Salvar cliente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar cliente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anotar para Dona Maria'));
    await tester.pumpAndSettle();

    expect(find.text('Venda registrada!'), findsOneWidget);
    final sale = sales.sales.single;
    expect(sale.method, PaymentMethod.credit);
    expect(sale.customer?.id, customers.customers.single.id);
  });

  test('o corpo da venda nunca leva preço nem total, e só o fiado leva cliente', () {
    const item = SaleItem(productId: 'rice', name: 'Arroz', unitPriceCents: 2500, quantity: 2, soldByWeight: false);
    const customer = SaleCustomer(id: 'c1', name: 'Dona Maria');

    final credit = SaleDto.toJson(const SaleInput(items: [item], method: PaymentMethod.credit, customer: customer));
    final cash = SaleDto.toJson(const SaleInput(items: [item], method: PaymentMethod.cash, customer: customer));

    expect(credit, {
      'paymentMethod': 'credit',
      'customerId': 'c1',
      'items': [
        {'productId': 'rice', 'quantity': 2.0},
      ],
    });
    expect(cash.containsKey('customerId'), isFalse);
  });
}
