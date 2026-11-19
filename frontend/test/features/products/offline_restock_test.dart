import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/offline/local_database.dart';
import 'package:vendaqui/core/offline/offline_reader.dart';
import 'package:vendaqui/core/offline/offline_status.dart';
import 'package:vendaqui/core/offline/offline_store.dart';
import 'package:vendaqui/core/offline/offline_writer.dart';
import 'package:vendaqui/core/offline/outbox.dart';
import 'package:vendaqui/features/products/data/pending_restock_sender.dart';
import 'package:vendaqui/features/products/data/products_remote_data_source.dart';
import 'package:vendaqui/features/products/data/products_repository_impl.dart';

import '../../support/fakes.dart';
import '../../support/scripted_api.dart';

void main() {
  test('reposição sem internet soma na cópia, sobe pela fila e a recusa guarda o motivo', () async {
    final api = ScriptedApi();
    final db = memoryDatabase();
    final store = OfflineStore(db);
    final outbox = Outbox(db, store)..register(PendingRestockSender.kind, const PendingRestockSender().send);
    await store.saveOwner((id: 'm1', name: 'Mercearia', phone: '+5586999990000'));
    await store.upsertProducts([
      LocalProductsCompanion.insert(
        id: 'p1',
        name: 'Arroz',
        searchKey: 'arroz',
        photoUrl: const Value(null),
        thumbUrl: const Value(null),
        salePriceCents: 500,
        costPriceCents: 300,
        quantity: 2,
        soldByWeight: false,
      ),
    ]);
    final ids = ['restock-1', 'restock-2'];
    final reader = OfflineReader(store, OfflineStatus());
    final repository = ProductsRepositoryImpl(
      ProductsRemoteDataSource(storageClient: Dio()),
      reader,
      OfflineWriter(reader, outbox, newId: () => ids.removeAt(0)),
    );

    expect(await repository.restock('p1', 5), SyncState.pending);
    expect(await repository.restock('p1', 3), SyncState.pending);
    expect((await store.product('p1'))?.quantity, 10);
    expect(api.requests, hasLength(1), reason: 'a segunda reposição não espera o timeout de novo');

    // A primeira sobe; a segunda é recusada (produto apagado em outro aparelho) e fica para o comerciante ver
    api.responses.addAll([
      (
        200,
        {
          'success': true,
          'message': 'Estoque atualizado.',
          'data': {'id': 'p1'},
        },
      ),
      (404, {'success': false, 'message': 'Produto não encontrado.', 'code': 'PRODUCT_NOT_FOUND'}),
    ]);
    final events = <OutboxEvent>[];
    outbox.events.listen(events.add);
    expect(await outbox.flush(), isTrue);
    final sent = api.requests.skip(1).toList();
    expect(sent.map((request) => request.path), ['/products/p1/restock', '/products/p1/restock']);
    expect(sent.map((request) => request.data), [
      {'quantity': 5.0, 'clientId': 'restock-1'},
      {'quantity': 3.0, 'clientId': 'restock-2'},
    ]);
    expect((outbox.pendingCount, outbox.rejectedCount), (0, 1));

    await pumpEventQueue();
    final rejected = events.singleWhere((event) => event.outcome == OutboxOutcome.rejected);
    expect(rejected.message, 'Produto não encontrado.');
    expect(rejected.payload['display'], {'name': 'Arroz', 'soldByWeight': false});
  });
}
