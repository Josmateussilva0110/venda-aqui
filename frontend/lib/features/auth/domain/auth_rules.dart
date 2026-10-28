/// Limites de PIN e código usados para feedback rápido; o backend revalida tudo.
abstract final class AuthRules {
  static const pinMinLength = 4;
  static const pinMaxLength = 6;
  static const recoveryCodeLength = 6;
}
