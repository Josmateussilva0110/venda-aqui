import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui/app/app.dart';
import 'package:vendaqui/app/dependencies.dart';
import 'package:vendaqui/core/offline/offline_status.dart';
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
          offlineStatus: OfflineStatus(),
          outbox: memoryOutbox(),
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
    await tester.enterText(find.byType(TextField).at(1), '86977776666');
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

  // O CPF só vem no detalhe do cliente: a edição mostra o que está guardado, não apaga sem querer
  // (editar o nome mantém o CPF, cliente sem CPF carregado não recebe "vazio") e apaga quando esvaziado
  group('CPF na edição', () {
    const withCpf = Customer(id: 'c3', name: 'Carla', phone: '+5586911112222', balanceCents: 0, cpf: '52998224725');

    Future<FakeCustomersRepository> openEdit(WidgetTester tester, Customer customer) async {
      final customers = FakeCustomersRepository(customers: [customer]);
      final router = await pumpApp(tester, customers);
      router.go(AppRoutes.customer(customer.id));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Editar cliente'));
      await tester.pumpAndSettle();
      return customers;
    }

    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
    }

    testWidgets('aparece formatado e continua igual ao editar o nome', (tester) async {
      final customers = await openEdit(tester, withCpf);
      expect(find.widgetWithText(TextField, '529.982.247-25'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Carla'), 'Carla Souza');
      await save(tester);
      expect(customers.lastUpdate?.cpf, '52998224725');
      expect(customers.customers.single.cpf, '52998224725');
    });

    testWidgets('esvaziar o campo apaga o CPF', (tester) async {
      final customers = await openEdit(tester, withCpf);
      await tester.enterText(find.widgetWithText(TextField, '529.982.247-25'), '');
      await save(tester);
      expect(customers.lastUpdate?.cpf, '');
      expect(customers.customers.single.cpf, isNull);
    });

    testWidgets('cliente sem CPF carregado não manda nada (não apaga o que estiver guardado)', (tester) async {
      final customers = await openEdit(tester, other);
      await tester.enterText(find.widgetWithText(TextField, 'João'), 'João Pedro');
      await save(tester);
      expect(customers.lastUpdate, isNotNull);
      expect(customers.lastUpdate?.cpf, isNull);
    });
  });

  testWidgets('CPF com dígito errado é recusado no campo, antes de ir ao servidor', (tester) async {
    final customers = FakeCustomersRepository(customers: [other]);
    final router = await pumpApp(tester, customers);
    router.go(AppRoutes.customer(other.id));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Editar cliente'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(2), '52998224726');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();
    expect(find.text('CPF inválido. Confira os 11 números.'), findsOneWidget);
    expect(customers.lastUpdate, isNull);
  });
}
