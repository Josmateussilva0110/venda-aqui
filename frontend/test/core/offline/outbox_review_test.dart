import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/offline/offline_store.dart';
import 'package:vendaqui/core/offline/outbox.dart';

import '../../support/fakes.dart';

void main() {
  test('só recusada pode ser descartada; a pendente continua guardada até subir', () async {
    final db = memoryDatabase();
    final store = OfflineStore(db);
    final outbox = Outbox(db, store);
    await store.saveOwner((id: 'm1', name: 'Mercearia', phone: '+5586999990000'));
    var serverAccepts = false;
    outbox.register('sale', (payload) async {
      if (payload['id'] == 'recusada') return (outcome: OutboxOutcome.rejected, detail: null, message: 'Produto apagado.');
      return serverAccepts
          ? (outcome: OutboxOutcome.sent, detail: null, message: null)
          : (outcome: OutboxOutcome.retryLater, detail: null, message: null);
    });
    var discards = 0;
    outbox.discarded.listen((_) => discards++);

    await outbox.add(id: 'recusada', kind: 'sale', payload: {'id': 'recusada'});
    await outbox.add(id: 'pendente', kind: 'sale', payload: {'id': 'pendente'});
    await outbox.flush();

    final changes = await outbox.list();
    expect(changes.map((change) => (change.id, change.rejected, change.reason)), [
      ('recusada', true, 'Produto apagado.'),
      ('pendente', false, null),
    ]);

    // Descartar a pendente não faz nada: perderia uma venda que o servidor aceitaria
    await outbox.discard('pendente');
    expect((outbox.pendingCount, outbox.rejectedCount), (1, 1));

    // Tentar de novo devolve a recusada para a fila (e o servidor recusa outra vez)
    await outbox.retry('recusada');
    expect((outbox.pendingCount, outbox.rejectedCount), (1, 1));

    await outbox.discard('recusada');
    await pumpEventQueue();
    expect((outbox.pendingCount, outbox.rejectedCount), (1, 0));
    expect(discards, 1, reason: 'a cópia local precisa vir de novo do servidor');

    serverAccepts = true;
    expect(await outbox.flush(), isTrue);
    expect(await outbox.list(), isEmpty);
  });
}
