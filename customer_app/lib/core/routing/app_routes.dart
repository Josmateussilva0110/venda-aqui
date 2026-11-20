/// Caminhos das telas. Dados pessoais (telefone, CPF) nunca vão na rota.
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';

  /// Onde o cliente cola o link de acesso que a loja mandou pelo WhatsApp.
  static const pasteInvite = '/invite/paste';

  /// Tela do link já lido: cria o acesso ou junta a loja ao acesso existente.
  static const invite = '/invite';
  static const inviteTokenParam = 'token';
  static String inviteWithToken(String token) => Uri(path: invite, queryParameters: {inviteTokenParam: token}).toString();

  static const stores = '/stores';

  /// Recebe a [Store] por `extra`; sem ela volta para a lista de lojas.
  static String storeStatement(String id) => '/stores/$id';

  /// Telas que não exigem login.
  static const publicRoutes = {login, invite, pasteInvite};

  /// O link chega pelo WhatsApp a qualquer hora: logado, ele junta mais uma loja ao acesso.
  static const inviteRoutes = {invite, pasteInvite};
}
