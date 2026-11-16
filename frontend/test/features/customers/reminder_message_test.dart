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

  String messageFor(OpenAccount account, DueStatus status, {String customer = 'Lucas', String? merchant = 'Zoro'}) =>
      reminderMessage(l10n, customerName: customer, account: account, status: status, merchantName: merchant, locale: 'pt_BR');

  // Exemplo real enviado pelo comerciante; valores alinhados à direita num bloco monoespaçado
  final lucas = OpenAccount(
    balanceCents: 2200,
    creditDueDate: DateTime(2027, 1, 1),
    paidCents: 0,
    purchases: [
      OpenPurchase(
        createdAt: DateTime(year, 11, 12, 9),
        totalCents: 400,
        items: const [PurchasedItem(name: 'Tomate', quantity: 2, soldByWeight: false, subtotalCents: 400)],
      ),
      OpenPurchase(
        createdAt: DateTime(year, 11, 13, 9),
        totalCents: 1800,
        items: const [
          PurchasedItem(name: 'Maçã', quantity: 1, soldByWeight: true, subtotalCents: 1200),
          PurchasedItem(name: 'Banana', quantity: 1, soldByWeight: true, subtotalCents: 600),
        ],
      ),
    ],
    earlierCount: 0,
    earlierCents: 0,
  );

  test('lista os itens com o valor alinhado à direita, num bloco monoespaçado', () {
    expect(
      messageFor(lucas, DueStatus.upcoming),
      'Olá, Lucas. Tudo bem?\n'
      'Gostaria de lembrar que o seu saldo em aberto conosco é de *R\$\u00a022,00*, com vencimento em *01/01/2027*.\n'
      '\n'
      '*Compras:*\n'
      '```\n'
      '12/11\n'
      '• 2 un Tomate    R\$\u00a04,00\n'
      '13/11\n'
      '• 1 kg Maçã     R\$\u00a012,00\n'
      '• 1 kg Banana    R\$\u00a06,00\n'
      '```\n'
      '\n'
      'Em caso de dúvida, estou à disposição.\n'
      'Atenciosamente, Zoro.',
    );
  });

  test('todas as linhas da lista têm a mesma largura, para o valor alinhar', () {
    final message = messageFor(lucas, DueStatus.upcoming);
    final block = message.split('```')[1].trim().split('\n').where((line) => line.startsWith('•'));
    expect(block.map((line) => line.length).toSet(), {24});
  });

  test('cada situação usa a sua abertura e o seu fechamento, e o já pago fica fora do bloco', () {
    final paid = OpenAccount(
      balanceCents: lucas.balanceCents,
      creditDueDate: lucas.creditDueDate,
      paidCents: 4655,
      purchases: lucas.purchases,
      earlierCount: 0,
      earlierCents: 0,
    );
    final due = messageFor(paid, DueStatus.due);
    expect(due, contains('hoje vence o seu saldo de *R\$ 22,00*'));
    expect(due, contains('```\n\n*Já pago:* R\$ 46,55\n\nEm caso de dúvida'));

    final overdue = messageFor(lucas, DueStatus.overdue);
    expect(overdue, contains('vencido em *01/01/2027*, ainda está em aberto.'));
    expect(overdue, contains('Caso precise de um novo prazo, é só responder esta mensagem.\nAtenciosamente, Zoro.'));
  });

  test('compras antigas viram resumo, nome longo é cortado e itens demais viram "Mais N itens" com a soma', () {
    final crowded = OpenAccount(
      balanceCents: 30000,
      creditDueDate: DateTime(year, 11, 20),
      paidCents: 0,
      purchases: [
        OpenPurchase(
          createdAt: DateTime(year, 11, 10, 8),
          totalCents: 10000,
          items: [
            const PurchasedItem(name: 'Biscoito recheado de chocolate meio amargo', quantity: 1, soldByWeight: false, subtotalCents: 1001),
            for (var i = 2; i <= 7; i++) PurchasedItem(name: 'Item $i', quantity: 1, soldByWeight: false, subtotalCents: 1000 + i),
          ],
        ),
      ],
      earlierCount: 3,
      earlierCents: 20000,
    );
    final message = messageFor(crowded, DueStatus.upcoming, merchant: null);
    expect(message, contains('```\n• +3 compras   R\$\u00a0200,00\n10/11\n• 1 un Biscoit… R\$\u00a010,01'));
    // Itens 6 e 7 somados (1006 + 1007), para a conta continuar fechando
    expect(message, contains('• Mais 2 itens  R\$\u00a020,13\n```'));
    expect(message, isNot(contains('Já pago')));
    expect(message, endsWith('\nAtenciosamente.'));
  });
}
