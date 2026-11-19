import 'package:drift/drift.dart' show Value;

import '../../../core/network/api_codes.dart';
import '../../../core/network/cancel_signal.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../../../core/offline/local_database.dart';
import '../../../core/offline/offline_reader.dart';
import '../../../core/offline/offline_store.dart';
import '../../../core/offline/offline_writer.dart';
import '../../../core/notifications/reminder_notifier.dart';
import '../../../core/utils/date_only.dart';
import '../../../core/utils/phone_format.dart';
import '../domain/customer.dart';
import '../domain/customers_repository.dart';
import 'pending_customer_sender.dart';
import 'pending_payment_sender.dart';

/// Clientes e fiado na API. Sem internet, a lista e o cliente vêm da cópia local, com o saldo
/// da última sincronização, e o pagamento recebido vai para a fila; extrato, cobrança, vencimento e
/// cadastro continuam só online.
class CustomersRepositoryImpl implements CustomersRepository {
  const CustomersRepositoryImpl(this._offline, this._writer);

  final OfflineReader _offline;
  final OfflineWriter _writer;

  @override
  Future<CustomerPage> list({
    required String search,
    required CustomerBalanceFilter balance,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  }) {
    return _offline.read(
      cancel: cancel,
      remote: () => _remoteList(search: search, balance: balance, offset: offset, limit: limit, cancel: cancel),
      save: (store, page) => store.upsertCustomers(page.items.map(_toLocal).toList()),
      local: (store) => _localList(store, search: search, balance: balance, offset: offset, limit: limit),
    );
  }

  Future<CustomerPage> _remoteList({
    required String search,
    required CustomerBalanceFilter balance,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  }) async {
    final response = await requestData<CustomerPage>(
      endpoint: ApiPaths.customers,
      params: {'search': search, 'balance': balance.apiValue, 'offset': offset, 'limit': limit},
      cancelToken: cancel?.token,
      parse: (json) {
        final data = jsonMap(json);
        final summary = data['summary'];
        return CustomerPage(
          items: data.requireMapList('items').map(_customerFromJson).toList(growable: false),
          total: data.requireInt('total'),
          summary: summary is Map<String, dynamic> ? _summaryFromJson(summary) : null,
        );
      },
    );
    return response.requireData();
  }

  @override
  Future<Customer> get(String id) {
    return _offline.read(
      remote: () async {
        final response = await requestData<Customer>(endpoint: ApiPaths.customer(id), parse: (json) => _customerFromJson(jsonMap(json)));
        return response.requireData();
      },
      save: (store, customer) => store.upsertCustomers([_toLocal(customer)]),
      local: (store) async {
        final row = await store.customer(id);
        return row == null ? null : _fromLocal(row);
      },
    );
  }

  // A API devolve só o id; cliente recém-cadastrado não deve nada
  // Sem internet o cadastro vai para a fila com o id já escolhido pelo aparelho: o cliente aparece na
  // lista na hora e pode receber venda fiado offline, que sobe depois dele (a fila respeita a ordem)
  @override
  Future<Customer> create(CustomerInput input) async {
    final name = input.name.trim();
    final write = await _writer.write(
      kind: PendingCustomerSender.kind,
      online: (clientId, budget) async {
        final response = await requestData<String>(
          endpoint: ApiPaths.customers,
          method: 'POST',
          data: PendingCustomerSender.body(input, clientId: clientId),
          cancelToken: budget.token,
          parse: (json) => jsonMap(json).requireString('id'),
        );
        return response.requireData();
      },
      queued: (clientId, _) => PendingCustomerSender.payload(body: PendingCustomerSender.body(input, clientId: clientId)),
      localEffects: (store, clientId) => store.upsertCustomers([
        LocalCustomersCompanion.insert(
          id: clientId,
          name: name,
          searchKey: OfflineStore.searchKeyOf(name),
          // Aproximado até a sincronização trazer o formato que o servidor gravou
          phone: '+${PhoneFormat.internationalDigits(input.phone)}',
          balanceCents: 0,
        ),
      ]),
    );
    return Customer(id: write.value ?? write.clientId, name: name, phone: input.phone, balanceCents: 0);
  }

  // A API devolve só o id; quem chamou busca o cliente de novo para ver o telefone já normalizado
  @override
  Future<void> update(String id, CustomerInput input) async {
    final response = await requestData<void>(endpoint: ApiPaths.customer(id), method: 'PUT', data: PendingCustomerSender.body(input));
    response.ensureSuccess();
  }

  @override
  Future<void> delete(String id) async {
    final response = await requestData<void>(endpoint: ApiPaths.customer(id), method: 'DELETE');
    response.ensureSuccess();
    await _offline.store.deleteCustomer(id);
  }

  @override
  Future<StatementPage> statement(String customerId, {required int offset, required int limit}) async {
    final response = await requestData<StatementPage>(
      endpoint: ApiPaths.customerStatement(customerId),
      params: {'offset': offset, 'limit': limit},
      parse: (json) {
        final data = jsonMap(json);
        return StatementPage(
          items: data.requireMapList('items').map(_entryFromJson).toList(growable: false),
          total: data.requireInt('total'),
        );
      },
    );
    return response.requireData();
  }

  // Dinheiro recebido sem internet não pode ficar sem registro: vai para a fila com a hora do recebimento.
  // O servidor confere de novo o teto (não pagar mais do que deve) quando a fila subir
  @override
  Future<PaymentReceipt> registerPayment(String customerId, {required int amountCents, required SettlementMethod method}) async {
    final customer = await _offline.store.customer(customerId);
    final write = await _writer.write(
      kind: PendingPaymentSender.kind,
      online: (clientId, budget) async {
        final response = await requestData<int>(
          endpoint: ApiPaths.customerPayments(customerId),
          method: 'POST',
          data: PendingPaymentSender.body(amountCents: amountCents, method: method, clientId: clientId),
          cancelToken: budget.token,
          parse: (json) => jsonMap(json).requireInt('balanceCents'),
        );
        return response.requireData();
      },
      queued: (clientId, paidAt) => PendingPaymentSender.payload(
        customerId: customerId,
        body: PendingPaymentSender.body(amountCents: amountCents, method: method, clientId: clientId, paidAt: paidAt),
        customerName: customer?.name ?? '',
      ),
      localEffects: (store, _) => store.applyPayment(customerId: customerId, amountCents: amountCents),
    );
    return PaymentReceipt(balanceCents: write.value, state: write.state);
  }

  @override
  Future<OpenAccount> openAccount(String customerId) async {
    final response = await requestData<OpenAccount>(
      endpoint: ApiPaths.customerOpenAccount(customerId),
      parse: (json) {
        final data = jsonMap(json);
        return OpenAccount(
          balanceCents: data.requireInt('balanceCents'),
          creditDueDate: DateOnly.tryParse(data.optionalString('creditDueDate')),
          paidCents: data.requireInt('paidCents'),
          purchases: data.requireMapList('purchases').map(_purchaseFromJson).toList(growable: false),
          earlierCount: data.requireInt('earlierCount'),
          earlierCents: data.requireInt('earlierCents'),
        );
      },
    );
    return response.requireData();
  }

  OpenPurchase _purchaseFromJson(Map<String, dynamic> json) {
    return OpenPurchase(
      createdAt: DateTime.parse(json.requireString('createdAt')).toLocal(),
      totalCents: json.requireInt('totalCents'),
      items: json
          .requireMapList('items')
          .map(
            (item) => PurchasedItem(
              name: item.requireString('name'),
              quantity: item.requireDouble('quantity'),
              soldByWeight: item.optionalBool('soldByWeight'),
              subtotalCents: item.requireInt('subtotalCents'),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<DateTime> setDueDate(String customerId, DateTime dueDate) async {
    final response = await requestData<DateTime>(
      endpoint: ApiPaths.customerDueDate(customerId),
      method: 'PUT',
      data: {'dueDate': DateOnly.toApi(dueDate)},
      parse: (json) => _requireDate(jsonMap(json), 'creditDueDate'),
    );
    return response.requireData();
  }

  @override
  Future<CreditReminderPage> reminders({required int offset, required int limit}) async {
    final response = await requestData<CreditReminderPage>(
      endpoint: ApiPaths.creditReminders,
      params: {'offset': offset, 'limit': limit},
      parse: (json) {
        final data = jsonMap(json);
        return CreditReminderPage(
          items: data.requireMapList('items').map(_reminderFromJson).toList(growable: false),
          total: data.requireInt('total'),
        );
      },
    );
    return response.requireData();
  }

  @override
  Future<void> markReminded(String customerId) async {
    final response = await requestData<void>(endpoint: ApiPaths.customerReminder(customerId), method: 'POST');
    response.ensureSuccess();
  }

  // O resumo vem junto da lista; uma linha só basta para lê-lo
  @override
  Future<CreditSummary> summary() async {
    final response = await requestData<CreditSummary>(
      endpoint: ApiPaths.customers,
      params: {'balance': CustomerBalanceFilter.owing.apiValue, 'limit': 1, 'offset': 0},
      parse: (json) => _summaryFromJson(jsonMap(json).requireMap('summary')),
    );
    return response.requireData();
  }

  @override
  Future<CreditSettings> creditSettings() async {
    final response = await requestData<CreditSettings>(
      endpoint: ApiPaths.creditSettings,
      parse: (json) {
        final data = jsonMap(json);
        return CreditSettings(
          creditTermDays: data.requireInt('creditTermDays'),
          remindersEnabled: data.optionalBool('remindersEnabled'),
          remindDaysBefore: data.requireInt('remindDaysBefore'),
          remindOnDue: data.optionalBool('remindOnDue'),
          remindOverdueEveryDays: data.requireInt('remindOverdueEveryDays'),
          reminderHour: data.requireInt('reminderHour'),
        );
      },
    );
    return response.requireData();
  }

  @override
  Future<void> saveCreditSettings(CreditSettings settings) async {
    final response = await requestData<void>(
      endpoint: ApiPaths.creditSettings,
      method: 'PUT',
      data: {
        'creditTermDays': settings.creditTermDays,
        'remindersEnabled': settings.remindersEnabled,
        'remindDaysBefore': settings.remindDaysBefore,
        'remindOnDue': settings.remindOnDue,
        'remindOverdueEveryDays': settings.remindOverdueEveryDays,
        'reminderHour': settings.reminderHour,
      },
    );
    response.ensureSuccess();
  }

  CreditSummary _summaryFromJson(Map<String, dynamic> json) {
    return CreditSummary(
      owingCount: json.requireInt('owingCount'),
      owedCents: json.requireInt('owedCents'),
      reminders: ReminderSchedule.fromSummaryJson(json['reminders']),
    );
  }

  // O resumo local não traz os lembretes: a agenda deles é calculada pelo servidor
  Future<CustomerPage> _localList(
    OfflineStore store, {
    required String search,
    required CustomerBalanceFilter balance,
    required int offset,
    required int limit,
  }) async {
    final page = await store.customers(search: search, owingOnly: balance == CustomerBalanceFilter.owing, offset: offset, limit: limit);
    final totals = offset == 0 ? await store.creditTotals() : null;
    return CustomerPage(
      items: page.items.map(_fromLocal).toList(growable: false),
      total: page.total,
      summary: totals == null ? null : CreditSummary(owingCount: totals.owingCount, owedCents: totals.owedCents),
    );
  }

  static Customer _fromLocal(LocalCustomer row) {
    return Customer(
      id: row.id,
      name: row.name,
      phone: row.phone,
      balanceCents: row.balanceCents,
      creditDueDate: DateOnly.tryParse(row.creditDueDate),
    );
  }

  static LocalCustomersCompanion _toLocal(Customer customer) {
    final dueDate = customer.creditDueDate;
    return LocalCustomersCompanion.insert(
      id: customer.id,
      name: customer.name,
      searchKey: OfflineStore.searchKeyOf(customer.name),
      phone: customer.phone,
      balanceCents: customer.balanceCents,
      creditDueDate: Value(dueDate == null ? null : DateOnly.toApi(dueDate)),
    );
  }

  Customer _customerFromJson(Map<String, dynamic> json) {
    return Customer(
      id: json.requireString('id'),
      name: json.requireString('name'),
      phone: json.requireString('phone'),
      balanceCents: json.requireInt('balanceCents'),
      creditDueDate: DateOnly.tryParse(json.optionalString('creditDueDate')),
      cpf: json.optionalString('cpf'),
    );
  }

  CreditReminder _reminderFromJson(Map<String, dynamic> json) {
    final status = DueStatus.fromApi(json.optionalString('kind'));
    if (status == null) throw const FormatException('Tipo de lembrete desconhecido');
    return CreditReminder(customer: _customerFromJson(json), status: status);
  }

  DateTime _requireDate(Map<String, dynamic> json, String key) {
    final date = DateOnly.tryParse(json.requireString(key));
    if (date == null) throw FormatException('Data inválida em $key');
    return date;
  }

  StatementEntry _entryFromJson(Map<String, dynamic> json) {
    final kind = switch (json.requireString('kind')) {
      'sale' => StatementEntryKind.sale,
      'payment' => StatementEntryKind.payment,
      final other => throw FormatException('Lançamento desconhecido: $other'),
    };
    return StatementEntry(
      kind: kind,
      id: json.requireString('id'),
      amountCents: json.requireInt('amountCents'),
      createdAt: DateTime.parse(json.requireString('createdAt')).toLocal(),
      settlementMethod: SettlementMethod.fromApi(json.optionalString('paymentMethod')),
    );
  }
}
