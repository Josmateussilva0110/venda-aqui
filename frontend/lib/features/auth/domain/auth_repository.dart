import 'merchant.dart';

/// Contrato de autenticação. Implementações lançam [AppFailure] em caso de erro.
abstract interface class AuthRepository {
  /// Restaura a sessão guardada no aparelho; nulo se não houver sessão válida.
  Future<Merchant?> restoreSession();

  Future<bool> isPhoneAvailable(String phoneDigits);

  Future<Merchant> register({required String name, required String phoneDigits, required String pin});

  Future<Merchant> login({required String phoneDigits, required String pin});

  Future<void> requestPinRecovery(String phoneDigits);

  Future<Merchant> confirmPinRecovery({required String phoneDigits, required String code, required String pin});

  Future<void> logout();
}
