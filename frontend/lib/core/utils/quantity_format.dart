import 'package:intl/intl.dart';

/// Quantidade de estoque: inteira para unidades, até 3 casas para kg.
abstract final class QuantityFormat {
  static const maxDecimals = 3;
  static final NumberFormat _weight = NumberFormat.decimalPatternDigits(locale: 'pt_BR')
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = maxDecimals;

  static String format(double quantity, {required bool soldByWeight}) {
    if (!soldByWeight) return quantity.round().toString();
    return _weight.format(quantity).replaceAll('.', '');
  }

  /// Aceita "1,25" ou "1.25". Nulo se não for número ou passar de 3 casas.
  static double? parse(String input) {
    final text = input.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d+(\.\d{1,3})?$').hasMatch(text)) return null;
    return double.parse(text);
  }
}
