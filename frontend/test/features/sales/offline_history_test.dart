import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/network/cancel_signal.dart';
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
import 'package:vendaqui/features/sales/presentation/controllers/sales_history_controller.dart';

import '../../support/fakes.dart';
import '../../support/scripted_api.dart';

/// Servidor com [serverSales] vendas de hoje; registra o offset pedido em cada página.
class _CountingRemote extends SalesRemoteDataSource {
  _CountingRemote(this.serverSales);

  final int serverSales;
  final offsets = <int>[];

  @override
  Future<SaleHistoryPage> history(SaleFilter filter, {required int offset, required int limit, CancelSignal? cancel}) async {
    offsets.add(offset);
    final count = (serverSales - offset).clamp(0, limit);
    return SaleHistoryPage(
      items: [
        for (var index = 0; index < count; index++)
          Sale(
            id: 'srv-${offset + index}',
            createdAt: DateTime(2026, 11, 16, 8).subtract(Duration(minutes: offset + index)),
            items: const [SaleItem(productId: 'p1', name: 'Feijão', unitPriceCents: 100, quantity: 1, soldByWeight: false)],
            method: PaymentMethod.pix,
            totalCents: 100,
          ),
      ],
      total: serverSales,
      totalCents: serverSales * 100,
    );
  }
}

const _rice = SaleItem(productId: 'p1', name: 'Arroz', unitPriceCents: 500, quantity: 2, soldByWeight: false);

void main() {
  test('vendas da fila entram na primeira página do histórico, e o "carregar mais" não pula vendas do servidor', () async {
    ScriptedApi(); // sem respostas: o registro online cai na fila
    final db = memoryDatabase();
    final store = OfflineStore(db);
    final outbox = Outbox(db, store)..register(PendingSaleSender.kind, const PendingSaleSender().send);
    await store.saveOwner((id: 'm1', name: 'Mercearia', phone: '+5586999990000'));
    final now = DateTime(2026, 11, 16, 10);
    final reader = OfflineReader(store, OfflineStatus(), clock: () => now);
    final ids = ['fila-1', 'fila-2'];
    final writer = OfflineWriter(reader, outbox, clock: () => now, newId: () => ids.removeAt(0));
    final remote = _CountingRemote(SalesHistoryController.pageSize + 10);
    final repository = SalesRepositoryImpl(const CatalogRemoteDataSource(), remote, reader, writer, outbox, clock: () => now);

    await repository.register(const SaleInput(items: [_rice], method: PaymentMethod.cash));
    await repository.register(const SaleInput(items: [_rice], method: PaymentMethod.card));

    // Filtro por forma de pagamento vale para a fila também
    final cashOnly = await repository.history(SaleFilter(from: now, to: now, method: PaymentMethod.cash), offset: 0, limit: 50);
    expect(cashOnly.items.where((sale) => sale.pendingSync).map((sale) => sale.id), ['fila-1']);

    final controller = SalesHistoryController(repository, clock: () => now);
    await controller.load();
    expect(controller.saleCount, SalesHistoryController.pageSize + 10 + 2);
    expect(controller.totalCents, (SalesHistoryController.pageSize + 10) * 100 + 2 * 1000);
    expect(controller.groups.single.sales.take(2).map((sale) => (sale.id, sale.pendingSync)), [('fila-1', true), ('fila-2', true)]);

    await controller.loadMore();
    // O servidor já mandou 50; as 2 da fila não contam no offset dele
    expect(remote.offsets.last, SalesHistoryController.pageSize);
    expect(controller.hasMore, isFalse);
    final ids0 = controller.groups.expand((group) => group.sales).map((sale) => sale.id).toList();
    expect(ids0.toSet(), hasLength(ids0.length), reason: 'nenhuma venda repetida');
    expect(ids0, hasLength(SalesHistoryController.pageSize + 10 + 2));
    controller.dispose();
  });

  test('sem internet o histórico mostra as vendas guardadas no aparelho', () async {
    ScriptedApi();
    final db = memoryDatabase();
    final store = OfflineStore(db);
    final outbox = Outbox(db, store)..register(PendingSaleSender.kind, const PendingSaleSender().send);
    await store.saveOwner((id: 'm1', name: 'Mercearia', phone: '+5586999990000'));
    final now = DateTime(2026, 11, 16, 10);
    final reader = OfflineReader(store, OfflineStatus(), clock: () => now);
    final writer = OfflineWriter(reader, outbox, clock: () => now, newId: () => 'fila-1');
    final repository = SalesRepositoryImpl(const CatalogRemoteDataSource(), const SalesRemoteDataSource(), reader, writer, outbox);
    await repository.register(const SaleInput(items: [_rice], method: PaymentMethod.cash));

    final page = await repository.history(SaleFilter(from: now, to: now), offset: 0, limit: 50);
    expect(page.onlyPending, isTrue);
    expect((page.total, page.totalCents), (1, 1000));
    expect(page.items.single.items.single.name, 'Arroz');
  });
}
