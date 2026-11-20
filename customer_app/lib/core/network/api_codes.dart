/// Códigos de erro da API do portal que mudam o comportamento do app (contrato com o backend).
abstract final class ApiCodes {
  static const accessTokenInvalid = 'PORTAL_ACCESS_TOKEN_INVALID';
  static const sessionInvalid = 'PORTAL_SESSION_INVALID';
  static const sessionExpired = 'PORTAL_SESSION_EXPIRED';
  static const sessionRevoked = 'PORTAL_SESSION_REVOKED';

  /// O link venceu, já foi usado ou a loja trocou o telefone do cadastro.
  static const inviteInvalid = 'PORTAL_INVITE_INVALID';

  /// A conta ainda não existe: o link precisa criar um PIN.
  static const inviteNeedsNewPin = 'PORTAL_INVITE_NEEDS_NEW_PIN';

  static const sessionEndingCodes = {sessionInvalid, sessionExpired, sessionRevoked};
}

/// Caminhos da API, relativos a `API_BASE_URL`.
abstract final class ApiPaths {
  static const inviteInspect = '/portal/invites/inspect';
  static const inviteAccept = '/portal/invites/accept';
  static const login = '/portal/auth/login';
  static const refresh = '/portal/auth/refresh';
  static const logout = '/portal/auth/logout';

  static const stores = '/portal/stores';
  static String storeStatement(String id) => '/portal/stores/$id/statement';
}
