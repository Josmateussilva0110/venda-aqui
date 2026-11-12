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

  /// Prolonga (ou adianta) o vencimento. O servidor aceita de hoje até um ano à frente.
  Future<DateTime> setDueDate(String customerId, DateTime dueDate);

  /// Clientes com lembrete pendente, do vencimento mais antigo para o mais novo.
  Future<CreditReminderPage> reminders({required int offset, required int limit});

  /// Registra que o lembrete foi aberto no WhatsApp; ele sai da lista até a próxima data de lembrete.
  Future<void> markReminded(String customerId);

  /// Resumo do fiado (com o agendamento dos lembretes), sem a lista de clientes.
  Future<CreditSummary> summary();

  Future<CreditSettings> creditSettings();

  Future<void> saveCreditSettings(CreditSettings settings);
}
