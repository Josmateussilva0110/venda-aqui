import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui/features/customers/domain/customer.dart';
import 'package:vendaqui/features/customers/presentation/widgets/reminder_message.dart';
import 'package:vendaqui/l10n/app_localizations.dart';

// A mensagem vai para o cliente: situação, valor ou data errados viram cobrança indevida
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  final l10n = lookupAppLocalizations(const Locale('pt'));
  final customer = Customer(
    id: 'c1',
    name: 'Maria das Graças',
    phone: '+5586999990000',
    balanceCents: 10345,
    creditDueDate: DateTime(DateTime.now().year, 11, 20),
  );

  String messageFor(DueStatus status, {String? merchant = 'José'}) =>
      reminderMessage(l10n, customer: customer, status: status, merchantName: merchant, locale: 'pt_BR');

  test('cada situação usa a sua mensagem, com valor e data do fiado', () {
    final upcoming = messageFor(DueStatus.upcoming);
    expect(upcoming, startsWith('Olá, Maria. Tudo bem?'));
    expect(upcoming, contains('saldo em aberto conosco é de *R\$ 103,45*, com vencimento em *20/11*'));
    expect(upcoming, endsWith('Atenciosamente, José.'));

    expect(messageFor(DueStatus.due), contains('hoje vence o seu saldo de *R\$ 103,45*'));

    final overdue = messageFor(DueStatus.overdue);
    expect(overdue, contains('vencido em *20/11*, ainda está em aberto'));
    expect(overdue, contains('novo prazo'));
  });

  test('sem nome do comerciante, assina só com "Atenciosamente."', () {
    expect(messageFor(DueStatus.due, merchant: null), endsWith('\nAtenciosamente.'));
  });
}
