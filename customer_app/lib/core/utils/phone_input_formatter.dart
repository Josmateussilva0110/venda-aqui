import 'package:flutter/services.dart';

import 'phone_format.dart';

/// Máscara "(00) 00000-0000" enquanto digita; o valor real são só os dígitos.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = PhoneFormat.digitsOnly(newValue.text);
    if (digits.length > PhoneFormat.maxDigits) digits = digits.substring(0, PhoneFormat.maxDigits);
    final text = PhoneFormat.display(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
