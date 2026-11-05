import '../../../core/network/api_codes.dart';
import '../../../core/network/cancel_signal.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
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

  CreditSummary _summaryFromJson(Map<String, dynamic> json) {
    return CreditSummary(owingCount: json.requireInt('owingCount'), owedCents: json.requireInt('owedCents'));
  }

  Customer _customerFromJson(Map<String, dynamic> json) {
    return Customer(
      id: json.requireString('id'),
      name: json.requireString('name'),
      phone: json.requireString('phone'),
      balanceCents: json.requireInt('balanceCents'),
    );
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
