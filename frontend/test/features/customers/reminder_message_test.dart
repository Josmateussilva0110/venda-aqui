import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui/features/customers/domain/customer.dart';
import 'package:vendaqui/features/customers/presentation/widgets/reminder_message.dart';
import 'package:vendaqui/l10n/app_localizations.dart';

// A mensagem vai para o cliente: situação, valor, data ou compras errados viram cobrança indevida
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  final l10n = lookupAppLocalizations(const Locale('pt'));
  final year = DateTime.now().year;
  final account = OpenAccount(
    balanceCents: 10345,
    creditDueDate: DateTime(year, 11, 20),
    paidCents: 4655,
    purchases: [
      OpenPurchase(
        createdAt: DateTime(year, 11, 3, 9),
        totalCents: 8250,
        items: const [
          PurchasedItem(name: 'Arroz', quantity: 2, soldByWeight: false),
          PurchasedItem(name: 'Tomate', quantity: 1.5, soldByWeight: true),
        ],
      ),
      OpenPurchase(
        createdAt: DateTime(year, 11, 8, 17),
        totalCents: 6750,
        items: const [
          PurchasedItem(name: 'Café', quantity: 1, soldByWeight: false),
          PurchasedItem(name: 'Pão', quantity: 3, soldByWeight: false),
        ],
      ),
    ],
    earlierCount: 0,
    earlierCents: 0,
  );

  String messageFor(DueStatus status, {OpenAccount? from, String? merchant = 'José'}) => reminderMessage(
    l10n,
    customerName: 'Maria das Graças',
    account: from ?? account,
    status: status,
    merchantName: merchant,
    locale: 'pt_BR',
  );

  test('lista as compras com itens e o já pago, no formato escolhido', () {
    expect(
      messageFor(DueStatus.upcoming),
      'Olá, Maria. Tudo bem?\n'
      'Gostaria de lembrar que o seu saldo em aberto conosco é de *R\$ 103,45*, com vencimento em *20/11*.\n'
      '\n'
      '*Compras:*\n'
      '• 03/11: 2 un Arroz, 1,5 kg Tomate — R\$ 82,50\n'
      '• 08/11: 1 un Café, 3 un Pão — R\$ 67,50\n'
      '*Já pago:* R\$ 46,55\n'
      '\n'
      'Em caso de dúvida, estou à disposição.\n'
      'Atenciosamente, José.',
    );
  });

  test('cada situação usa a sua abertura e o seu fechamento', () {
    final due = messageFor(DueStatus.due);
    expect(due, contains('hoje vence o seu saldo de *R\$ 103,45*'));
    expect(due, contains('Em caso de dúvida'));

    final overdue = messageFor(DueStatus.overdue);
    expect(overdue, contains('vencido em *20/11*, ainda está em aberto.'));
    expect(overdue, contains('Caso precise de um novo prazo, é só responder esta mensagem.\nAtenciosamente, José.'));
  });

  test('compras antigas viram resumo, itens demais viram "e mais N", sem pago some a linha', () {
    final crowded = OpenAccount(
      balanceCents: 30000,
      creditDueDate: DateTime(year, 11, 20),
      paidCents: 0,
      purchases: [
        OpenPurchase(
          createdAt: DateTime(year, 11, 10, 8),
          totalCents: 10000,
          items: [for (var i = 1; i <= 7; i++) PurchasedItem(name: 'Item $i', quantity: 1, soldByWeight: false)],
        ),
      ],
      earlierCount: 3,
      earlierCents: 20000,
    );
    final message = messageFor(DueStatus.upcoming, from: crowded, merchant: null);
    expect(message, contains('• 3 compras anteriores — R\$ 200,00\n• 10/11: 1 un Item 1'));
    expect(message, contains('1 un Item 5 e mais 2 — R\$ 100,00'));
    expect(message, isNot(contains('Já pago')));
    expect(message, endsWith('\nAtenciosamente.'));
  });
}
