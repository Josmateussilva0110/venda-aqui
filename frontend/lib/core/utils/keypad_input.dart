/// Teclas do teclado numérico próprio do app.
sealed class KeypadKey {
  const KeypadKey();
}

final class DigitKey extends KeypadKey {
  const DigitKey(this.digit);
  final String digit;
}

final class DecimalKey extends KeypadKey {
  const DecimalKey();
}

final class BackspaceKey extends KeypadKey {
  const BackspaceKey();
}

/// Regras de edição do valor digitado no teclado próprio.
abstract final class KeypadInput {
  static const decimalSeparator = ',';
  static const _maxDecimalLength = 7;
  static const _maxDecimalPlaces = 3;

  /// Só dígitos, até [maxLength] (PIN, telefone, código).
  static String applyDigits(String value, KeypadKey key, {required int maxLength}) {
    return switch (key) {
      BackspaceKey() => value.isEmpty ? value : value.substring(0, value.length - 1),
      DigitKey(:final digit) => value.length < maxLength ? value + digit : value,
      DecimalKey() => value,
    };
  }

  /// Número com vírgula e até 3 casas (peso em kg).
  static String applyDecimal(String value, KeypadKey key) {
    switch (key) {
      case BackspaceKey():
        return value.isEmpty ? value : value.substring(0, value.length - 1);
      case DecimalKey():
        if (value.contains(decimalSeparator)) return value;
        return '${value.isEmpty ? '0' : value}$decimalSeparator';
      case DigitKey(:final digit):
        final parts = value.split(decimalSeparator);
        if (parts.length > 1 && parts[1].length >= _maxDecimalPlaces) return value;
        if (value.length >= _maxDecimalLength) return value;
        if (value == '0') return digit;
        return value + digit;
    }
  }
}
