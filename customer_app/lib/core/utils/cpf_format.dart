/// CPF: 11 dígitos, mostrado como "000.000.000-00". Trafega e é guardado só com os dígitos.
abstract final class CpfFormat {
  static const digitsLength = 11;

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  /// Formata enquanto o usuário digita.
  static String display(String digits) {
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index == 3 || index == 6) buffer.write('.');
      if (index == 9) buffer.write('-');
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  /// Conferência de UX dos dígitos verificadores; o servidor confere de novo.
  /// Sequências repetidas ("111.111.111-11") passam na conta mas não existem.
  static bool isValid(String digits) {
    if (digits.length != digitsLength || RegExp(r'^(\d)\1{10}$').hasMatch(digits)) return false;
    return _checkDigit(digits, 9) == int.parse(digits[9]) && _checkDigit(digits, 10) == int.parse(digits[10]);
  }

  static int _checkDigit(String digits, int length) {
    var sum = 0;
    for (var index = 0; index < length; index++) {
      sum += int.parse(digits[index]) * (length + 1 - index);
    }
    final rest = (sum * 10) % 11;
    return rest == 10 ? 0 : rest;
  }
}
