import 'package:flutter/services.dart';

import 'cpf_format.dart';

/// Máscara "000.000.000-00" enquanto digita; o valor real são só os dígitos.
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = CpfFormat.digitsOnly(newValue.text);
    if (digits.length > CpfFormat.digitsLength) digits = digits.substring(0, CpfFormat.digitsLength);
    final text = CpfFormat.display(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
