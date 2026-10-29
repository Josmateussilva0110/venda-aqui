/// Caminhos das telas. Dados pessoais (telefone etc.) nunca vão na URL: usam `extra`.
abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const recoverPin = '/recover-pin';

  static const home = '/home';
  static const settings = '/settings';
  static const stock = '/stock';

  /// Filtro do estoque na URL (`all`, `low` ou `out`): é por ela que o início abre o estoque já filtrado.
  static const stockFilterParam = 'filter';
  static String stockFiltered(String? filter) =>
      Uri(path: stock, queryParameters: filter == null ? null : {stockFilterParam: filter}).toString();
  static const productNew = '/stock/new';
  static String productEdit(String id) => '/stock/$id/edit';
  static String productRestock(String id) => '/stock/$id/restock';

  static const authRoutes = {welcome, login, register, recoverPin};
}
