import 'package:flutter/foundation.dart';

/// Cliente do comércio. O saldo do fiado é calculado e guardado pelo servidor.
@immutable
class Customer {
  const Customer({required this.id, required this.name, required this.phone, required this.balanceCents});

  final String id;
  final String name;

  /// Como a API devolve (+55DDDNÚMERO); a tela formata.
  final String phone;

  /// Quanto o cliente deve de fiado agora.
  final int balanceCents;

  bool get owes => balanceCents > 0;

  Customer copyWith({int? balanceCents}) => Customer(id: id, name: name, phone: phone, balanceCents: balanceCents ?? this.balanceCents);
}

/// Dados para cadastrar um cliente. O servidor normaliza nome e telefone.
@immutable
class CustomerInput {
  const CustomerInput({required this.name, required this.phone});

  final String name;
  final String phone;
}

/// Fiado do comércio inteiro, independente do filtro e da página.
@immutable
class CreditSummary {
  const CreditSummary({required this.owingCount, required this.owedCents});

  final int owingCount;
  final int owedCents;
}

enum CustomerBalanceFilter {
  owing('owing'),
  all('all');

  const CustomerBalanceFilter(this.apiValue);

  final String apiValue;
}

@immutable
class CustomerPage {
  const CustomerPage({required this.items, required this.total, this.summary});

  final List<Customer> items;
  final int total;

  /// Só vem na primeira página: não muda entre as páginas.
  final CreditSummary? summary;
}

/// Formas aceitas para receber o fiado (pagar fiado com fiado não existe).
enum SettlementMethod {
  cash('cash'),
  pix('pix'),
  card('card');

  const SettlementMethod(this.apiValue);

  final String apiValue;

  static SettlementMethod? fromApi(String? value) {
    for (final method in values) {
      if (method.apiValue == value) return method;
    }
    return null;
  }
}

enum StatementEntryKind { sale, payment }

/// Lançamento da conta: venda fiado (aumenta a dívida) ou pagamento (diminui).
@immutable
class StatementEntry {
  const StatementEntry({required this.kind, required this.id, required this.amountCents, required this.createdAt, this.settlementMethod});

  final StatementEntryKind kind;

  /// Id da venda ou do pagamento.
  final String id;
  final int amountCents;
  final DateTime createdAt;

  /// Só nos pagamentos.
  final SettlementMethod? settlementMethod;
}

@immutable
class StatementPage {
  const StatementPage({required this.items, required this.total});

  final List<StatementEntry> items;
  final int total;
}
