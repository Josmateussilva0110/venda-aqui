import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui/app/app.dart';
import 'package:vendaqui/app/dependencies.dart';
import 'package:vendaqui/core/routing/app_routes.dart';
import 'package:vendaqui/core/stock/stock_changes.dart';
import 'package:vendaqui/features/auth/domain/merchant.dart';
import 'package:vendaqui/features/auth/presentation/controllers/session_controller.dart';

import '../../support/fakes.dart';

class _RecordingAuth extends FakeAuthRepository {
  _RecordingAuth({this.phoneAvailable = true}) : super(signedIn: false);

  final bool phoneAvailable;
  String? registeredPin;

  @override
  Future<bool> isPhoneAvailable(String phoneDigits) async => phoneAvailable;

  @override
  Future<Merchant> register({required String name, required String phoneDigits, required String pin}) async {
    registeredPin = pin;
    return testMerchant;
  }
}

/// Cadastro inteiro digitado pelo teclado do sistema: a conta só é criada com o PIN repetido igual.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<void> openRegister(WidgetTester tester, _RecordingAuth auth) async {
    final dependencies = AppDependencies(
      authRepository: auth,
      productsRepository: FakeProductsRepository(),
      dashboardRepository: FakeDashboardRepository(),
      photoPicker: FakePhotoPicker(),
      sessionController: SessionController(auth),
      stockChanges: StockChanges(),
      themeController: lightThemeController(),
    );
    await tester.pumpWidget(VendaquiApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Navigator).first)).go(AppRoutes.register);
    await tester.pumpAndSettle();
  }

  testWidgets('telefone já cadastrado avisa no toast e não segue para o PIN', (tester) async {
    await openRegister(tester, _RecordingAuth(phoneAvailable: false));

    await tester.enterText(find.byType(TextField).at(0), 'Zezim');
    await tester.enterText(find.byType(TextField).at(1), '89988168802');
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.descendant(of: find.byType(SnackBar), matching: find.textContaining('já')), findsOneWidget);
    expect(find.textContaining('Entrar com este telefone'), findsNothing);
    expect(find.text('Repita o PIN'), findsNothing);
  });

  testWidgets('cria a conta depois de repetir o PIN', (tester) async {
    final auth = _RecordingAuth();
    await openRegister(tester, auth);

    await tester.enterText(find.byType(TextField).at(0), 'Mercearia da Rita');
    await tester.enterText(find.byType(TextField).at(1), '86999990000');
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '2580');
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Repita o PIN'), findsWidgets);

    // PIN diferente: limpa e pede de novo, sem criar a conta
    await tester.enterText(find.byType(TextField), '2581');
    await tester.pumpAndSettle();
    expect(find.text('Os PINs não conferem. Tente de novo.'), findsOneWidget);
    expect(auth.registeredPin, isNull);

    await tester.enterText(find.byType(TextField), '2580');
    await tester.pumpAndSettle();
    expect(auth.registeredPin, '2580');
  });
}
