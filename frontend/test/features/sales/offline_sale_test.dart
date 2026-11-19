import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/network/app_failure.dart';
import 'package:vendaqui/core/network/cancel_signal.dart';
import 'package:vendaqui/core/offline/local_database.dart';
import 'package:vendaqui/core/offline/offline_reader.dart';
import 'package:vendaqui/core/offline/offline_status.dart';
import 'package:vendaqui/core/offline/offline_store.dart';
import 'package:vendaqui/core/offline/offline_writer.dart';
import 'package:vendaqui/core/offline/outbox.dart';
import 'package:vendaqui/features/sales/data/catalog_remote_data_source.dart';
import 'package:vendaqui/features/sales/data/pending_sale_sender.dart';
import 'package:vendaqui/features/sales/data/sales_remote_data_source.dart';
import 'package:vendaqui/features/sales/data/sales_repository_impl.dart';
import 'package:vendaqui/features/sales/domain/sale.dart';

import '../../support/fakes.dart';
import '../../support/scripted_api.dart';

/// Registro online que falha por rede (ou responde), contando as tentativas e os clientIds enviados.
class _FlakySalesRemote extends SalesRemoteDataSource {
  _FlakySalesRemote({required this.online});

  bool online;
  final List<String> sentClientIds = [];

  @override
  Future<({String id, int totalCents})> register(SaleInput input, {required String clientId, CancelSignal? cancel}) async {
    sentClientIds.add(clientId);
    if (!online) throw const NetworkFailure();
    return (id: 'server-$clientId', totalCents: 1000);
  }
}

const _owner = (id: 'm1', name: 'Mercearia', phone: '+5586999990000');
const _rice = SaleItem(productId: 'p1', name: 'Arroz', unitPriceCents: 500, quantity: 3, soldByWeight: false);
const _customer = SaleCustomer(id: 'c1', name: 'Ana');

(int, Map<String, Object?>) _saved({List<Map<String, Object?>> shortfalls = const []}) => (
  201,
  {
    'success': true,
    'message': 'Venda registrada com sucesso.',
    'data': {'id': 's1', 'totalCents': 1500, 'stockShortfalls': shortfalls, 'replayed': false},
  },
);

void main() {
  late LocalDatabase db;
  late OfflineStore store;
  late Outbox outbox;

  setUp(() async {
    db = memoryDatabase();
    store = OfflineStore(db);
    outbox = Outbox(db, store)..register(PendingSaleSender.kind, const PendingSaleSender().send);
    await store.saveOwner(_owner);
    await store.replaceAll(
      products: [
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
      ],
      customers: [LocalCustomersCompanion.insert(id: 'c1', name: 'Ana', searchKey: 'ana', phone: '+5586988880000', balanceCents: 0)],
      lowStockThreshold: 5,
      syncedAt: DateTime(2026, 11, 15, 9),
    );
  });

  test('sem internet a venda vai para a fila com o mesmo id já tentado, e a cópia reflete estoque e fiado', () async {
    var now = DateTime(2026, 11, 15, 14, 32);
    final ids = ['venda-1', 'venda-2'];
    final remote = _FlakySalesRemote(online: false);
    final reader = OfflineReader(store, OfflineStatus(), clock: () => now);
    final writer = OfflineWriter(reader, outbox, clock: () => now, newId: () => ids.removeAt(0));
    final repository = SalesRepositoryImpl(const CatalogRemoteDataSource(), remote, reader, writer, outbox, clock: () => now);

    final sale = await repository.register(const SaleInput(items: [_rice], method: PaymentMethod.credit, customer: _customer));

    expect(sale.pendingSync, isTrue);
    expect(sale.id, 'venda-1');
    expect(sale.totalCents, 1500);
    expect(outbox.pendingCount, 1);
    final entry = await db.select(db.outboxEntries).getSingle();
    final payload = PendingSaleSender.bodyOf(jsonDecode(entry.payload) as Map<String, dynamic>);
    // O id que pode ter chegado ao servidor é o mesmo da fila: o reenvio não duplica
    expect(payload['clientId'], remote.sentClientIds.single);
    expect(DateTime.parse(payload['soldAt'] as String).toLocal(), now);
    expect((await store.product('p1'))?.quantity, 0, reason: 'baixa sem passar de zero, como o servidor');
    expect((await store.customer('c1'))?.balanceCents, 1500);

    // Logo em seguida, com sinal ruim, a próxima venda nem tenta o servidor (sem esperar o timeout no balcão)
    now = now.add(const Duration(seconds: 5));
    await repository.register(const SaleInput(items: [_rice], method: PaymentMethod.cash));
    expect(remote.sentClientIds, hasLength(1));
    expect(outbox.pendingCount, 2);
  });

  test('a fila sobe na ordem, guarda a recusa, para na falta de internet e avisa a falta de estoque', () async {
    final api = ScriptedApi();
    var clock = DateTime(2026, 11, 15, 10);
    final orderedOutbox = Outbox(db, store, clock: () => clock = clock.add(const Duration(minutes: 1)))
      ..register(PendingSaleSender.kind, const PendingSaleSender().send);
    Future<void> enqueue(String id) => orderedOutbox.add(
      id: id,
      kind: PendingSaleSender.kind,
      payload: {'clientId': id, 'soldAt': '2026-11-15T13:00:00.000Z', 'paymentMethod': 'cash', 'items': []},
    );
    await enqueue('a');
    await enqueue('b');
    await enqueue('c');
    final events = <OutboxEvent>[];
    orderedOutbox.events.listen(events.add);
    final flushes = <Set<String>>[];
    orderedOutbox.flushed.listen(flushes.add);

    // "a" foi recusada (produto apagado), "b" pegou a conexão caindo: "c" espera atrás dela
    api.responses.addAll([
      (409, {'success': false, 'message': 'Um dos produtos não existe mais. Atualize a lista.', 'code': 'SALE_PRODUCT_NOT_FOUND'}),
      null,
    ]);
    expect(await orderedOutbox.flush(), isFalse);
    expect(api.requests.map((request) => (request.data as Map)['clientId']), ['a', 'b']);
    expect((orderedOutbox.pendingCount, orderedOutbox.rejectedCount), (2, 1));

    api.responses.addAll([
      _saved(
        shortfalls: [
          {'productId': 'p1', 'name': 'Arroz', 'missingQuantity': 1},
        ],
      ),
      _saved(),
    ]);
    expect(await orderedOutbox.flush(), isTrue);
    expect(api.requests.skip(2).map((request) => (request.data as Map)['clientId']), ['b', 'c']);
    expect((orderedOutbox.pendingCount, orderedOutbox.rejectedCount), (0, 1));

    await pumpEventQueue();
    // Um aviso de recarga por envio (não por venda): telas abertas recarregam uma vez só
    expect(flushes, [
      {PendingSaleSender.kind},
    ]);
    final rejected = events.firstWhere((event) => event.outcome == OutboxOutcome.rejected);
    expect(rejected.message, 'Um dos produtos não existe mais. Atualize a lista.');
    final receipt = events.where((event) => event.outcome == OutboxOutcome.sent).first.detail! as PendingSaleReceipt;
    expect(receipt.shortfalls.single.name, 'Arroz');
    expect(receipt.shortfalls.single.missingQuantity, 1);
  });

  test('a fila de outro comércio no aparelho não é enviada nem apagada ao trocar de conta', () async {
    await outbox.add(id: 'venda-m1', kind: PendingSaleSender.kind, payload: {'clientId': 'venda-m1'});

    await store.saveOwner((id: 'm2', name: 'Padaria', phone: '+5586977770000'));
    await outbox.refreshCounts();
    expect(outbox.pendingCount, 0);
    expect(await outbox.flush(), isTrue, reason: 'nada do m2 para enviar; a venda do m1 não vai na conta errada');

    await store.saveOwner(_owner);
    await outbox.refreshCounts();
    expect(outbox.pendingCount, 1);
  });
}
