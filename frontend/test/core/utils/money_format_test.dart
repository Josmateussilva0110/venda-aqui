import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/utils/money_format.dart';

// Preço errado vai para o banco e para o lucro: a conversão texto -> centavos precisa ser exata
void main() {
  test('converte o que o usuário digita em centavos sem erro de ponto flutuante', () {
    expect(MoneyFormat.parseCents('8,50'), 850);
    expect(MoneyFormat.parseCents('8,5'), 850);
    expect(MoneyFormat.parseCents('0,10'), 10);
    expect(MoneyFormat.parseCents('1.234,56'), 123456);
    expect(MoneyFormat.parseCents('1.234'), 123400);
    expect(MoneyFormat.parseCents('8.50'), 850);
    expect(MoneyFormat.parseCents('R\$ 12'), 1200);
    expect(MoneyFormat.parseCents('19,99'), 1999);
  });

  test('recusa valores ambíguos ou com mais de 2 casas', () {
    expect(MoneyFormat.parseCents(''), isNull);
    expect(MoneyFormat.parseCents('8,505'), isNull);
    expect(MoneyFormat.parseCents('abc'), isNull);
    expect(MoneyFormat.parseCents('1,2,3'), isNull);
  });

  test('o valor exibido no campo de edição volta ao mesmo número de centavos', () {
    for (final cents in [0, 5, 850, 123456, 99999999]) {
      expect(MoneyFormat.parseCents(MoneyFormat.toInput(cents)), cents);
    }
  });
}
