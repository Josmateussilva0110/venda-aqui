/// Códigos de erro da API que mudam o comportamento do app (contrato com o backend).
abstract final class ApiCodes {
  static const accessTokenInvalid = 'ACCESS_TOKEN_INVALID';
  static const sessionInvalid = 'SESSION_INVALID';
  static const sessionExpired = 'SESSION_EXPIRED';
  static const sessionRevoked = 'SESSION_REVOKED';
  static const pinLocked = 'PIN_LOCKED';
  static const phoneAlreadyRegistered = 'PHONE_ALREADY_REGISTERED';
  static const recoveryCodeInvalid = 'RECOVERY_CODE_INVALID';

  static const sessionEndingCodes = {sessionInvalid, sessionExpired, sessionRevoked};
}

/// Caminhos da API, relativos a `API_BASE_URL`.
abstract final class ApiPaths {
  static const phoneCheck = '/auth/phone/check';
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/auth/me';
  static const pinRecoveryRequest = '/auth/pin-recovery/request';
  static const pinRecoveryConfirm = '/auth/pin-recovery/confirm';

  static const products = '/products';
  static String product(String id) => '/products/$id';
  static String productRestock(String id) => '/products/$id/restock';
  static String productPhotoUploadUrl(String id) => '/products/$id/photo/upload-url';
  static String productPhoto(String id) => '/products/$id/photo';
}
