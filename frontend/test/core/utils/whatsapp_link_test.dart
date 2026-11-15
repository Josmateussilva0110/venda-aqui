import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/utils/whatsapp_link.dart';

// Número errado manda a cobrança do fiado (nome e dívida) para outra pessoa
void main() {
  test('monta o link com o número internacional do cliente', () {
    expect(WhatsAppLink.chat('+5586999990000').toString(), 'https://wa.me/5586999990000');
    expect(WhatsAppLink.chat('(86) 99999-0000').toString(), 'https://wa.me/5586999990000');
    expect(WhatsAppLink.chat('8632210000').toString(), 'https://wa.me/558632210000');
  });

  test('a mensagem vai codificada e com espaço de verdade, sem "+"', () {
    final link = WhatsAppLink.chat('+5586999990000', message: 'Olá, Maria! Fiado: R\$ 103,45 & obrigado');
    expect(link.toString(), isNot(contains('+')));
    expect(link.queryParameters['text'], 'Olá, Maria! Fiado: R\$ 103,45 & obrigado');
  });
}
