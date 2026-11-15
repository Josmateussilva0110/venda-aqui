import '../../../core/network/api_codes.dart';
import '../../../core/network/cancel_signal.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../../../core/notifications/reminder_notifier.dart';
import '../../../core/utils/date_only.dart';
import '../domain/customer.dart';
import '../domain/customers_repository.dart';

/// Clientes e fiado direto na API (sem cache local: o saldo muda a cada venda e pagamento).
class CustomersRepositoryImpl implements CustomersRepository {
  const CustomersRepositoryImpl();

  @override
  Future<CustomerPage> list({
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
  Future<Customer> get(String id) async {
    final response = await requestData<Customer>(endpoint: ApiPaths.customer(id), parse: (json) => _customerFromJson(jsonMap(json)));
    return response.requireData();
  }

  // A API devolve só o id; cliente recém-cadastrado não deve nada
  @override
  Future<Customer> create(CustomerInput input) async {
    final response = await requestData<String>(
      endpoint: ApiPaths.customers,
      method: 'POST',
      data: {'name': input.name, 'phone': input.phone},
      parse: (json) => jsonMap(json).requireString('id'),
    );
    final id = response.requireData();
    return Customer(id: id, name: input.name.trim(), phone: input.phone, balanceCents: 0);
  }

  // A API devolve só o id; quem chamou busca o cliente de novo para ver o telefone já normalizado
  @override
  Future<void> update(String id, CustomerInput input) async {
    final response = await requestData<void>(
      endpoint: ApiPaths.customer(id),
      method: 'PUT',
      data: {'name': input.name, 'phone': input.phone},
    );
    response.ensureSuccess();
  }

  @override
  Future<void> delete(String id) async {
    final response = await requestData<void>(endpoint: ApiPaths.customer(id), method: 'DELETE');
    response.ensureSuccess();
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

  @override
  Future<int> registerPayment(String customerId, {required int amountCents, required SettlementMethod method}) async {
    final response = await requestData<int>(
      endpoint: ApiPaths.customerPayments(customerId),
      method: 'POST',
      data: {'amountCents': amountCents, 'paymentMethod': method.apiValue},
      parse: (json) => jsonMap(json).requireInt('balanceCents'),
    );
    return response.requireData();
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

  Customer _customerFromJson(Map<String, dynamic> json) {
    return Customer(
      id: json.requireString('id'),
      name: json.requireString('name'),
      phone: json.requireString('phone'),
      balanceCents: json.requireInt('balanceCents'),
      creditDueDate: DateOnly.tryParse(json.optionalString('creditDueDate')),
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
