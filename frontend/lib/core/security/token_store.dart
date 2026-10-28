import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Guarda os dados de sessão. O access token (15 min) fica só em memória;
/// o refresh token e o id do aparelho vão para o Keychain/Keystore, nunca para SharedPreferences.
class TokenStore {
  TokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _refreshTokenKey = 'session.refresh_token';
  static const _deviceIdKey = 'device.id';

  String? _accessToken;
  String? _deviceId;

  String? get accessToken => _accessToken;

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearSession() async {
    _accessToken = null;
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Id estável por instalação, exigido pela API para amarrar a sessão ao aparelho.
  Future<String> deviceId() async {
    final cached = _deviceId;
    if (cached != null) return cached;
    final stored = await _storage.read(key: _deviceIdKey);
    if (stored != null) return _deviceId = stored;
    final created = const Uuid().v4();
    await _storage.write(key: _deviceIdKey, value: created);
    return _deviceId = created;
  }
}
