import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui_cliente/app/app.dart';
import 'package:vendaqui_cliente/app/dependencies.dart';
import 'package:vendaqui_cliente/core/routing/app_routes.dart';
import 'package:vendaqui_cliente/core/theme/theme_controller.dart';
import 'package:vendaqui_cliente/features/auth/domain/invite_info.dart';
import 'package:vendaqui_cliente/features/auth/presentation/controllers/session_controller.dart';
import 'package:vendaqui_cliente/features/stores/domain/store.dart';

import '../support/fakes.dart';

/// Abre cada tela em vários tamanhos e com fonte aumentada, e falha com qualquer overflow.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  const viewports = <String, Size>{
    'celular pequeno': Size(320, 568),
    'celular comum': Size(390, 844),
    'celular em paisagem': Size(844, 390),
    'tablet em paisagem': Size(1024, 768),
  };
  const textScales = [1.0, 1.3];
  final inviteRoute = AppRoutes.inviteWithToken('a' * 43);
  final storeWithDueDate = Store(
    id: testStore.id,
    merchantName: testStore.merchantName,
    customerName: testStore.customerName,
    balanceCents: testStore.balanceCents,
    creditDueDate: DateTime(2026, 12, 5),
  );

  Future<void> pumpApp(WidgetTester tester, {required bool signedIn, required bool hasAccount}) async {
    final auth = FakeAuthRepository(
      signedIn: signedIn,
      inviteInfo: InviteInfo(merchantName: testStore.merchantName, phoneEnding: '0000', hasAccount: hasAccount),
    );
    final dependencies = AppDependencies(
      authRepository: auth,
      storesRepository: FakeStoresRepository(stores: [storeWithDueDate, testStore]),
      sessionController: SessionController(auth),
      themeController: ThemeController(MemoryThemeStore()),
    );
    await tester.pumpWidget(VendaquiClienteApp(key: UniqueKey(), dependencies: dependencies));
    await tester.pumpAndSettle();
  }

  Future<void> visit(WidgetTester tester, String location, {Object? extra}) async {
    final router = GoRouter.of(tester.element(find.byType(Navigator).first))..go(location, extra: extra);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'erro de layout em $location');
    // Garante que a tela abriu de fato (e não foi redirecionada para outra)
    expect(router.routerDelegate.currentConfiguration.uri.path, Uri.parse(location).path);
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

        await pumpApp(tester, signedIn: false, hasAccount: false);
        await visit(tester, AppRoutes.login);
        await visit(tester, AppRoutes.pasteInvite);
        await visit(tester, inviteRoute);
        // Sem token: a tela de link inválido
        await visit(tester, AppRoutes.invite);

        // Conta existente: PIN atual e, depois do "esqueci", o aviso das outras lojas com dois campos
        await pumpApp(tester, signedIn: false, hasAccount: true);
        await visit(tester, inviteRoute);
        final forgotPin = find.text('Esqueci o PIN, criar um novo');
        await tester.ensureVisible(forgotPin);
        await tester.pumpAndSettle();
        await tester.tap(forgotPin);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'erro de layout no "esqueci o PIN"');
        expect(find.text('Repita o PIN'), findsOneWidget);

        await pumpApp(tester, signedIn: true, hasAccount: true);
        await visit(tester, AppRoutes.stores);
        await visit(tester, AppRoutes.pasteInvite);
        await visit(tester, AppRoutes.storeStatement(testStore.id), extra: storeWithDueDate);
      });
    }
  }
}
