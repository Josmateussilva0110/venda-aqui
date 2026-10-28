import 'package:intl/intl.dart';

/// Dinheiro trafega em centavos inteiros; texto só na borda (campo e exibição).
abstract final class MoneyFormat {
  static const _locale = 'pt_BR';
  static final NumberFormat _currency = NumberFormat.currency(locale: _locale, symbol: r'R$', decimalDigits: 2);
  static final NumberFormat _plain = NumberFormat.decimalPatternDigits(locale: _locale, decimalDigits: 2);

  /// "R$ 8,50"
  static String format(int cents) => _currency.format(cents / 100);

  /// "8,50", para pré-preencher o campo de edição.
  static String toInput(int cents) => _plain.format(cents / 100).replaceAll('.', '');

  /// Converte o que o usuário digitou ("8,5", "1.234,56", "8.50") em centavos. Nulo se inválido.
  static int? parseCents(String input) {
    var text = input.trim().replaceAll(RegExp(r'[R$\s]'), '');
    if (text.isEmpty) return null;

    final hasComma = text.contains(',');
    if (hasComma) {
      // Formato brasileiro: ponto separa milhar, vírgula separa centavos
      text = text.replaceAll('.', '').replaceAll(',', '.');
    } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(text)) {
      text = text.replaceAll('.', '');
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) return null;

    final parts = text.split('.');
    final reais = int.parse(parts[0]);
    final centsPart = parts.length > 1 ? parts[1].padRight(2, '0') : '00';
    return reais * 100 + int.parse(centsPart);
  }
}
