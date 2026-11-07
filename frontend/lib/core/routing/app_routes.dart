/// Caminhos das telas. Dados pessoais (telefone etc.) nunca vão na URL: usam `extra`.
abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const recoverPin = '/recover-pin';

  static const home = '/home';
  static const sell = '/sell';
  static const sellWeight = '/sell/weight';
  static const sellSummary = '/sell/summary';
  static const sellPayment = '/sell/payment';
  static const sellDone = '/sell/done';
  static const salesHistory = '/sales';
  static String sale(String id) => '/sales/$id';
  static String saleEdit(String id) => '/sales/$id/edit';
  static const reports = '/reports';
  static const customers = '/customers';
  static String customer(String id) => '/customers/$id';

  /// Escolha do cliente do fiado; recebe o valor por `extra` e devolve o cliente escolhido.
  static const customerPicker = '/customers/pick';
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

/// O que a venda (ou a edição) manda para a escolha do cliente do fiado. Fica no núcleo porque
/// liga duas features: a venda abre a tela e a feature de clientes a desenha.
typedef CustomerPickerRequest = ({int amountCents, int? itemCount, String? initialCustomerId});

/// Cliente escolhido para o fiado, devolvido pela tela de escolha.
typedef PickedCustomer = ({String id, String name});
