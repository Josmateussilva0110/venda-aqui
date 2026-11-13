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
import 'package:vendaqui/features/customers/domain/customer.dart';

import '../../support/fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  const other = Customer(id: 'c2', name: 'João', phone: '+5586988887777', balanceCents: 0);

  Future<GoRouter> pumpApp(WidgetTester tester, FakeCustomersRepository customers) async {
    final auth = FakeAuthRepository(signedIn: true);
    final sales = FakeSalesRepository();
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
          reminderNotifier: FakeReminderNotifier(),
          customersRepository: customers,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return GoRouter.of(tester.element(find.byType(Navigator).first));
  }

  // Telefone errado manda a cobrança do fiado para outra pessoa: a edição tem que gravar o número novo
  // e recusar, no próprio campo, um telefone que já é de outro cliente
  testWidgets('edita nome e telefone e a conta mostra os dados novos', (tester) async {
    final customers = FakeCustomersRepository(customers: [testCustomer, other]);
    final router = await pumpApp(tester, customers);
    router.go(AppRoutes.customer(testCustomer.id));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Editar cliente'));
    await tester.pumpAndSettle();
    final nameField = find.widgetWithText(TextField, testCustomer.name);
    final phoneField = find.widgetWithText(TextField, '(86) 99999-0000');
    expect(nameField, findsOneWidget);
    expect(phoneField, findsOneWidget);

    await tester.enterText(phoneField, '86988887777');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();
    expect(find.text('Você já tem um cliente com esse telefone.'), findsOneWidget);
    expect(customers.customers.first.phone, testCustomer.phone);

    await tester.enterText(nameField, 'Maria Santos');
    await tester.enterText(find.byType(TextField).last, '86977776666');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(find.text('Conta do cliente'), findsOneWidget);
    expect(find.text('Maria Santos'), findsOneWidget);
    expect(find.text('(86) 97777-6666'), findsOneWidget);
    expect(customers.customers.first.phone, '+5586977776666');
    // Editar não mexe na dívida
    expect(customers.customers.first.balanceCents, testCustomer.balanceCents);
  });

  // Excluir apaga de vez: cliente com fiado no histórico fica, sem histórico sai e a conta fecha junto
  testWidgets('exclui só cliente sem histórico e volta para a lista', (tester) async {
    final customers = FakeCustomersRepository(customers: [testCustomer, other]);
    final router = await pumpApp(tester, customers);
    router.go(AppRoutes.customers);
    await tester.pumpAndSettle();

    Future<void> deleteFromAccount(String customerId) async {
      unawaited(router.push(AppRoutes.customer(customerId)));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Editar cliente'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Excluir cliente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
    }

    await deleteFromAccount(testCustomer.id);
    expect(find.text('Este cliente tem fiado no histórico e não pode ser excluído.'), findsOneWidget);
    expect(find.text('Editar cliente'), findsOneWidget);
    expect(customers.customers, contains(testCustomer));

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await deleteFromAccount(other.id);
    expect(customers.customers, isNot(contains(other)));
    expect(find.text('Fiado'), findsOneWidget);
    expect(find.text('Conta do cliente'), findsNothing);
  });
}
