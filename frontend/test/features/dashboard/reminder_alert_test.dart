import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui/app/app.dart';
import 'package:vendaqui/app/dependencies.dart';
import 'package:vendaqui/core/notifications/reminder_notifier.dart';
import 'package:vendaqui/core/stock/stock_changes.dart';
import 'package:vendaqui/features/auth/presentation/controllers/session_controller.dart';
import 'package:vendaqui/features/dashboard/domain/stock_overview.dart';

import '../../support/fakes.dart';

// O aviso só serve se levar aos lembretes: tocar nele (app fechado ou aberto) e no sino abre a lista
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<void> pumpApp(WidgetTester tester, FakeReminderNotifier notifier, {int pending = 0}) async {
    final auth = FakeAuthRepository(signedIn: true);
    final sales = FakeSalesRepository();
    await tester.pumpWidget(
      VendaquiApp(
        dependencies: AppDependencies(
          authRepository: auth,
          productsRepository: FakeProductsRepository(),
          dashboardRepository: FakeDashboardRepository(
            credit: CreditOverview(
              owingCount: 1,
              owedCents: testCustomer.balanceCents,
              reminders: ReminderSchedule(dueCount: pending, nextOn: null, hour: 9),
            ),
          ),
          photoPicker: FakePhotoPicker(),
          sessionController: SessionController(auth),
          stockChanges: StockChanges(),
          themeController: lightThemeController(),
          salesRepository: sales,
          saleCart: saleCartFor(sales),
          reportsRepository: FakeReportsRepository(),
          reminderNotifier: notifier,
          customersRepository: FakeCustomersRepository(customers: [testCustomer]),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('app aberto pelo aviso vai direto para os lembretes', (tester) async {
    await pumpApp(tester, FakeReminderNotifier(launchedFromAlert: true));
    expect(find.text('Lembretes de hoje'), findsOneWidget);

    // Voltar leva ao início, não à tela de abertura
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Configurações'), findsOneWidget);
  });

  testWidgets('toque no aviso com o app aberto abre os lembretes uma vez só', (tester) async {
    final notifier = FakeReminderNotifier();
    await pumpApp(tester, notifier);
    expect(find.text('Lembretes de hoje'), findsNothing);

    notifier.tapAlert();
    await tester.pumpAndSettle();
    notifier.tapAlert();
    await tester.pumpAndSettle();
    expect(find.text('Lembretes de hoje'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Lembretes de hoje'), findsNothing);
  });

  testWidgets('o sino mostra quantos lembretes faltam e abre a lista', (tester) async {
    await pumpApp(tester, FakeReminderNotifier(), pending: 3);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byTooltip('Lembretes do fiado: 3 para enviar'));
    await tester.pumpAndSettle();
    expect(find.text('Lembretes de hoje'), findsOneWidget);
  });
}
