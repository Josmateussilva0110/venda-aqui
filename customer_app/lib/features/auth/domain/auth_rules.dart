/// Limites de PIN usados para feedback rápido; o backend revalida tudo.
abstract final class AuthRules {
  static const pinMinLength = 4;
  static const pinMaxLength = 6;

  static bool isPinLengthValid(String pin) => pin.length >= pinMinLength && pin.length <= pinMaxLength;
}
