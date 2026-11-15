import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/features/customers/domain/customer.dart';
import 'package:vendaqui/features/customers/presentation/controllers/credit_reminders_controller.dart';

import '../../support/fakes.dart';

// Enviado sai da consulta do servidor: errar o deslocamento pula ou repete clientes na lista
void main() {
  test('depois de enviar, a próxima página continua sem pular nem repetir ninguém', () async {
    final customers = [
      for (var i = 0; i < 45; i++)
        Customer(
          id: 'c$i',
          name: 'Cliente ${i.toString().padLeft(2, '0')}',
          phone: '+55869999900${i.toString().padLeft(2, '0')}',
          balanceCents: 100,
        ),
    ];
    final repository = FakeCustomersRepository(customers: customers);
    final controller = CreditRemindersController(repository);

    await controller.loadFirstPage();
    expect(controller.items, hasLength(CreditRemindersController.pageSize));

    for (final reminder in controller.items.take(5).toList()) {
      await controller.markSent(reminder.customer.id);
    }
    expect(controller.hasMore, isTrue);

    await controller.loadMore();
    final ids = controller.items.map((reminder) => reminder.customer.id).toList();
    expect(ids.toSet(), hasLength(45));
    expect(ids, hasLength(45));
    expect(controller.hasMore, isFalse);
    expect(controller.changed, isTrue);
  });
}
