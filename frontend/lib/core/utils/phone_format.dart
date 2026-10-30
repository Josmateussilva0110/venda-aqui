/// Telefone brasileiro com DDD: 10 (fixo) ou 11 (celular) dígitos.
abstract final class PhoneFormat {
  static const minDigits = 10;
  static const maxDigits = 11;

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static bool isComplete(String digits) => digits.length >= minDigits && digits.length <= maxDigits;

  /// Formata enquanto o usuário digita: "(86) 99999-0000".
  static String display(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 2) return '($digits';
    final area = digits.substring(0, 2);
    final number = digits.substring(2);
    if (number.length <= 5) return '($area) $number';
    final split = number.length - 4;
    return '($area) ${number.substring(0, split)}-${number.substring(split)}';
  }

  /// A API devolve "+5586999990000"; na tela mostramos só o número nacional formatado.
  static String fromE164(String e164) {
    final digits = digitsOnly(e164);
    final national = digits.startsWith('55') && digits.length > maxDigits ? digits.substring(2) : digits;
    return display(national);
  }
}
