import 'package:flutter/services.dart';

import 'quantity_format.dart';

/// Quantidade digitada no teclado do sistema: só inteiros para unidades, ou kg com vírgula e até 3 casas.
/// O teclado de alguns aparelhos mostra ponto em vez de vírgula; os dois são aceitos e viram vírgula.
class QuantityInputFormatter extends TextInputFormatter {
  QuantityInputFormatter({required this.decimal});

  final bool decimal;

  static const decimalSeparator = ',';
  static const _maxIntegerDigits = 4;

  late final _pattern = decimal
      ? RegExp('^\\d{0,$_maxIntegerDigits}(,\\d{0,${QuantityFormat.maxDecimals}})?\$')
      : RegExp('^\\d{0,$_maxIntegerDigits}\$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('.', decimalSeparator);
    if (text.startsWith(decimalSeparator)) text = '0$text';
    if (!_pattern.hasMatch(text)) return oldValue;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
