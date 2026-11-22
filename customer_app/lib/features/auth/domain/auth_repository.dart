import 'invite_info.dart';
import 'login_method.dart';

abstract interface class AuthRepository {
  /// Verdadeiro se a sessão guardada ainda vale. Lança [NetworkFailure] sem conexão.
  Future<bool> restoreSession();

  /// [identifierDigits] são só os dígitos do telefone ou do CPF, conforme o [method].
  Future<void> login({required LoginMethod method, required String identifierDigits, required String pin});

  Future<InviteInfo> inspectInvite(String token);

  /// Com [currentPin] liga a loja à conta existente; com [newPin] cria a conta ou redefine o PIN.
  Future<void> acceptInvite({required String token, String? currentPin, String? newPin});

  Future<void> logout();
}
