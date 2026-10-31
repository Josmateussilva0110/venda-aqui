import '../../../core/network/app_failure.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/security/session_refresher.dart';
import '../../../core/security/token_store.dart';
import '../domain/auth_repository.dart';
import '../domain/merchant.dart';
import 'auth_dtos.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._remote, required this._tokenStore, required this._refresher});

  final AuthRemoteDataSource _remote;
  final TokenStore _tokenStore;
  final SessionRefresher _refresher;

  @override
  Future<Merchant?> restoreSession() async {
    final outcome = await _refresher.refresh();
    switch (outcome) {
      case RefreshOutcome.sessionEnded:
        await _tokenStore.clearSession();
        return null;
      case RefreshOutcome.unreachable:
        throw const NetworkFailure();
      case RefreshOutcome.renewed:
        return _remote.me();
    }
  }

  @override
  Future<bool> isPhoneAvailable(String phoneDigits) => _remote.checkPhone(phoneDigits);

  @override
  Future<Merchant> register({required String name, required String phoneDigits, required String pin}) async {
    final session = await _remote.register(name: name, phone: phoneDigits, pin: pin, deviceId: await _tokenStore.deviceId());
    return _start(session);
  }

  @override
  Future<Merchant> login({required String phoneDigits, required String pin}) async {
    final session = await _remote.login(phone: phoneDigits, pin: pin, deviceId: await _tokenStore.deviceId());
    return _start(session);
  }

  @override
  Future<void> requestPinRecovery(String phoneDigits) => _remote.requestPinRecovery(phoneDigits);

  @override
  Future<Merchant> confirmPinRecovery({required String phoneDigits, required String code, required String pin}) async {
    final session = await _remote.confirmPinRecovery(phone: phoneDigits, code: code, pin: pin, deviceId: await _tokenStore.deviceId());
    return _start(session);
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

  Future<Merchant> _start(SessionDto session) async {
    await _tokenStore.saveTokens(accessToken: session.accessToken, refreshToken: session.refreshToken);
    return session.merchant;
  }
}
