import 'package:flutter/foundation.dart';

import '../../../core/notifications/reminder_notifier.dart';
import '../../../core/utils/date_only.dart';

/// Cliente do comércio. O saldo do fiado é calculado e guardado pelo servidor.
@immutable
class Customer {
  const Customer({required this.id, required this.name, required this.phone, required this.balanceCents, this.creditDueDate});

  final String id;
  final String name;

  /// Como a API devolve (+55DDDNÚMERO); a tela formata.
  final String phone;

  /// Quanto o cliente deve de fiado agora.
  final int balanceCents;

  /// Até quando o fiado deve ser pago; o servidor define e limpa junto com o saldo.
  final DateTime? creditDueDate;

  bool get owes => balanceCents > 0;

  /// Situação do vencimento hoje; nula quando não deve.
  DueStatus? dueStatusOn(DateTime today) {
    final due = creditDueDate;
    if (!owes || due == null) return null;
    final days = DateOnly.daysBetween(today, due);
    return days > 0 ? DueStatus.upcoming : (days == 0 ? DueStatus.due : DueStatus.overdue);
  }

  // Quitou: o servidor apaga o vencimento na mesma transação, então aqui some também
  Customer copyWith({int? balanceCents, DateTime? creditDueDate}) {
    final balance = balanceCents ?? this.balanceCents;
    return Customer(
      id: id,
      name: name,
      phone: phone,
      balanceCents: balance,
      creditDueDate: balance == 0 ? null : creditDueDate ?? this.creditDueDate,
    );
  }
}

/// Antes do vencimento, vence hoje ou já venceu. Decide a mensagem do lembrete.
enum DueStatus {
  upcoming('upcoming'),
  due('due'),
  overdue('overdue');

  const DueStatus(this.apiValue);

  final String apiValue;

  static DueStatus? fromApi(String? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }
}

/// Cliente com lembrete pendente. [status] vem do servidor, com o "hoje" dele.
@immutable
class CreditReminder {
  const CreditReminder({required this.customer, required this.status});

  final Customer customer;
  final DueStatus status;
}

@immutable
class CreditReminderPage {
  const CreditReminderPage({required this.items, required this.total});

  final List<CreditReminder> items;
  final int total;
}

/// Prazo do fiado e quando lembrar. Zero em [remindDaysBefore] e [remindOverdueEveryDays] desliga aquele lembrete.
@immutable
class CreditSettings {
  const CreditSettings({
    required this.creditTermDays,
    required this.remindersEnabled,
    required this.remindDaysBefore,
    required this.remindOnDue,
    required this.remindOverdueEveryDays,
    required this.reminderHour,
  });

  final int creditTermDays;
  final bool remindersEnabled;
  final int remindDaysBefore;
  final bool remindOnDue;
  final int remindOverdueEveryDays;
  final int reminderHour;

  CreditSettings copyWith({
    int? creditTermDays,
    bool? remindersEnabled,
    int? remindDaysBefore,
    bool? remindOnDue,
    int? remindOverdueEveryDays,
    int? reminderHour,
  }) {
    return CreditSettings(
      creditTermDays: creditTermDays ?? this.creditTermDays,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      remindDaysBefore: remindDaysBefore ?? this.remindDaysBefore,
      remindOnDue: remindOnDue ?? this.remindOnDue,
      remindOverdueEveryDays: remindOverdueEveryDays ?? this.remindOverdueEveryDays,
      reminderHour: reminderHour ?? this.reminderHour,
    );
  }
}

/// Limites aceitos pelo servidor (iguais às constraints do banco); aqui só limitam os seletores.
abstract final class CreditSettingsLimits {
  static const termMin = 1;
  static const termMax = 180;
  static const beforeMax = 30;
  static const overdueEveryMax = 30;
  static const hourMin = 0;
  static const hourMax = 23;

  /// Prolongar vai até um ano à frente.
  static const dueDateMaxDays = 365;
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
  const CreditSummary({required this.owingCount, required this.owedCents, this.reminders});

  final int owingCount;
  final int owedCents;

  /// Nulo com os lembretes desligados.
  final ReminderSchedule? reminders;
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
