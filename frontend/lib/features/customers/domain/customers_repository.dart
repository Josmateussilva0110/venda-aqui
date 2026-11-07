import '../../../core/network/cancel_signal.dart';
import 'customer.dart';

/// Clientes e fiado. Busca, filtro, paginação e saldo são calculados pelo servidor.
abstract interface class CustomersRepository {
  /// Em ordem alfabética, com o resumo do fiado do comércio.
  Future<CustomerPage> list({
    required String search,
    required CustomerBalanceFilter balance,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  });

  Future<Customer> get(String id);

  Future<Customer> create(CustomerInput input);

  /// Do lançamento mais recente para o mais antigo.
  Future<StatementPage> statement(String customerId, {required int offset, required int limit});

  /// Devolve o saldo que sobrou. O servidor recusa pagamento maior que a dívida.
  Future<int> registerPayment(String customerId, {required int amountCents, required SettlementMethod method});
}
