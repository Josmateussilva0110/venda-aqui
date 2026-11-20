import '../../../core/network/app_failure.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/security/session_refresher.dart';
import '../../../core/security/token_store.dart';
import '../domain/auth_repository.dart';
import '../domain/invite_info.dart';
import '../domain/login_method.dart';
import 'auth_dtos.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._remote, required this._tokenStore, required this._refresher});

  final AuthRemoteDataSource _remote;
  final TokenStore _tokenStore;
  final SessionRefresher _refresher;

  @override
  Future<bool> restoreSession() async {
    switch (await _refresher.refresh()) {
      case RefreshOutcome.renewed:
        return true;
      case RefreshOutcome.sessionEnded:
        await _tokenStore.clearSession();
        return false;
      case RefreshOutcome.unreachable:
        throw const NetworkFailure();
    }
  }

  @override
  Future<void> login({required LoginMethod method, required String identifierDigits, required String pin}) async {
    final tokens = await _remote.login(
      method: method,
      identifierDigits: identifierDigits,
      pin: pin,
      deviceId: await _tokenStore.deviceId(),
    );
    await _save(tokens);
  }

  @override
  Future<InviteInfo> inspectInvite(String token) => _remote.inspectInvite(token);

  @override
  Future<void> acceptInvite({required String token, String? currentPin, String? newPin}) async {
    final tokens = await _remote.acceptInvite(token: token, currentPin: currentPin, newPin: newPin, deviceId: await _tokenStore.deviceId());
    await _save(tokens);
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } on AppFailure {
      // Mesmo sem conseguir avisar o servidor, a sessão local sai do aparelho
    } finally {
      await _tokenStore.clearSession();
    }
  }

  Future<void> _save(SessionTokens tokens) {
    return _tokenStore.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
  }
}
