import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui_cliente/features/auth/domain/invite_link.dart';

void main() {
  final token = 'Ab3_-' * 8 + 'xyz';

  // Se a leitura falhar, o cliente fica sem como entrar: o link é o único caminho para criar o acesso
  test('acha o token na mensagem inteira, no link ou sozinho', () {
    const message = 'Olá! Este é o seu acesso às compras na Loja A.\nCopie e cole no app Vendaqui Cliente: ';
    expect(InviteLink.tokenFrom('${message}vendaqui-cliente://convite?token=$token'), token);
    expect(InviteLink.tokenFrom('https://vendaqui.app/convite?token=$token '), token);
    expect(InviteLink.tokenFrom('  $token\n'), token);
  });

  test('texto sem link não vira token', () {
    expect(InviteLink.tokenFrom('Oi, tudo bem?'), isNull);
    expect(InviteLink.tokenFrom('vendaqui-cliente://convite?token=curto'), isNull);
  });
}
