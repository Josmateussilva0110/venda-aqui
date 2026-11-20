import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui_cliente/app/router.dart';
import 'package:vendaqui_cliente/core/routing/app_routes.dart';
import 'package:vendaqui_cliente/features/auth/presentation/controllers/session_controller.dart';

void main() {
  test('sem login, as compras não abrem: volta para o acesso', () {
    expect(redirectFor(SessionStatus.signedOut, AppRoutes.stores), AppRoutes.login);
    expect(redirectFor(SessionStatus.signedOut, AppRoutes.storeStatement('x')), AppRoutes.login);
  });

  // O link chega pelo WhatsApp a qualquer hora: logado, ele junta mais uma loja ao acesso
  test('o link da loja abre em qualquer estado da sessão', () {
    for (final status in SessionStatus.values) {
      expect(redirectFor(status, AppRoutes.invite), isNull, reason: '$status');
      expect(redirectFor(status, AppRoutes.pasteInvite), isNull, reason: '$status');
    }
  });

  test('logado, a tela de acesso leva às lojas', () {
    expect(redirectFor(SessionStatus.signedIn, AppRoutes.login), AppRoutes.stores);
    expect(redirectFor(SessionStatus.signedIn, AppRoutes.splash), AppRoutes.stores);
    expect(redirectFor(SessionStatus.signedIn, AppRoutes.storeStatement('x')), isNull);
  });
}
