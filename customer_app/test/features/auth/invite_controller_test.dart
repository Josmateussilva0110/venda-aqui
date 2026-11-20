import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui_cliente/core/network/app_failure.dart';
import 'package:vendaqui_cliente/features/auth/domain/invite_info.dart';
import 'package:vendaqui_cliente/features/auth/presentation/controllers/invite_controller.dart';

import '../../support/fakes.dart';

void main() {
  const token = 'token-do-link';
  const existing = InviteInfo(merchantName: 'Loja B', phoneEnding: '0000', hasAccount: true);

  Future<InviteController> loaded(FakeAuthRepository auth) async {
    final controller = InviteController(auth, token: token);
    await controller.load();
    return controller;
  }

  // O servidor decide pelo campo enviado: PIN atual só liga a loja; PIN novo desliga as outras.
  // Trocar um pelo outro mudaria o que acontece com as lojas do cliente
  test('conta existente envia o PIN atual; "esqueci o PIN" envia um PIN novo', () async {
    final auth = FakeAuthRepository(inviteInfo: existing);
    final controller = await loaded(auth);
    expect(controller.mode, InviteMode.currentPin);

    controller.setPin('2468');
    expect(await controller.submit(), isTrue);

    final resetAuth = FakeAuthRepository(inviteInfo: existing);
    final reset = await loaded(resetAuth);
    reset
      ..toggleForgotPin()
      ..setPin('1357')
      ..setConfirmation('1357');
    expect(await reset.submit(), isTrue);

    expect(auth.acceptCalls.single, (token: token, currentPin: '2468', newPin: null));
    expect(resetAuth.acceptCalls.single, (token: token, currentPin: null, newPin: '1357'));
  });

  test('PIN novo com confirmação diferente não sai do aparelho', () async {
    final auth = FakeAuthRepository(inviteInfo: existing.copyWithoutAccount());
    final controller = await loaded(auth);
    controller
      ..setPin('1357')
      ..setConfirmation('1358');

    expect(await controller.submit(), isFalse);
    expect(controller.issue, isA<InvitePinsDiffer>());
    expect(auth.acceptCalls, isEmpty);
  });

  test('link que deixou de valer no envio vira a tela de link inválido', () async {
    final auth = FakeAuthRepository(
      inviteInfo: existing,
      acceptFailure: const RequestFailure(statusCode: 410, message: 'x', code: 'PORTAL_INVITE_INVALID'),
    );
    final controller = await loaded(auth);
    controller.setPin('2468');

    expect(await controller.submit(), isFalse);
    expect(controller.state, isA<InviteInvalid>());
  });

  test('sem token na URL, nem consulta o servidor', () async {
    final controller = InviteController(FakeAuthRepository(inviteInfo: existing), token: null);
    await controller.load();
    expect(controller.state, isA<InviteInvalid>());
  });
}

extension on InviteInfo {
  InviteInfo copyWithoutAccount() => InviteInfo(merchantName: merchantName, phoneEnding: phoneEnding, hasAccount: false);
}
