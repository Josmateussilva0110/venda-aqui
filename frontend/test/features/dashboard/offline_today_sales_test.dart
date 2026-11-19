import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/offline/offline_reader.dart';
import 'package:vendaqui/core/offline/offline_status.dart';
import 'package:vendaqui/core/offline/offline_store.dart';
import 'package:vendaqui/core/offline/outbox.dart';
import 'package:vendaqui/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:vendaqui/app/pending_sales_today.dart';

import '../../support/fakes.dart';
import '../../support/scripted_api.dart';

Map<String, dynamic> _queuedSale(int totalCents) => {
  'body': {'clientId': 'x'},
  'display': {
    'totalCents': totalCents,
    'itemCount': 1,
    'method': 'cash',
    'productNames': ['Arroz'],
  },
};

void main() {
  test('vendas de hoje somam o que está na fila, e sem internet usam o último resumo do dia', () async {
    final api = ScriptedApi();
    final db = memoryDatabase();
    final store = OfflineStore(db);
    var clock = DateTime(2026, 11, 16, 9);
    final outbox = Outbox(db, store, clock: () => clock)
      ..register('sale', (payload) async {
        final rejected = payload['body'] is Map && (payload['body'] as Map)['clientId'] == 'recusada';
        return rejected
            ? (outcome: OutboxOutcome.rejected, detail: null, message: 'Recusada.')
            : (outcome: OutboxOutcome.retryLater, detail: null, message: null);
      });
    await store.saveOwner((id: 'm1', name: 'Mercearia', phone: '+5586999990000'));
    await store.replaceAll(products: const [], customers: const [], lowStockThreshold: 5, syncedAt: DateTime(2026, 11, 16, 8));
    final repository = DashboardRepositoryImpl(OfflineReader(store, OfflineStatus(), clock: () => clock), pendingSalesToday(outbox));

    // Hoje recusada (não soma: o servidor não vai registrar), ontem (não soma) e hoje na fila (soma)
    clock = DateTime(2026, 11, 16, 7);
    await outbox.add(
      id: 'recusada',
      kind: 'sale',
      payload: {
        ..._queuedSale(777),
        'body': {'clientId': 'recusada'},
      },
    );
    await outbox.flush();
    clock = DateTime(2026, 11, 15, 22);
    await outbox.add(id: 'ontem', kind: 'sale', payload: _queuedSale(999));
    clock = DateTime(2026, 11, 16, 10);
    await outbox.add(id: 'hoje', kind: 'sale', payload: _queuedSale(1500));

    // Com internet: servidor + fila, e o resumo do servidor fica guardado
    api.responses.add((
      200,
      {
        'success': true,
        'message': 'Vendas carregadas.',
        'data': {
          'total': 3,
          'totalCents': 6000,
          'items': [
            {
              'id': 's1',
              'items': [
                {'name': 'Feijão'},
              ],
              'createdAt': '2026-11-16T12:00:00.000Z',
              'paymentMethod': 'pix',
              'totalCents': 2000,
            },
          ],
        },
      },
    ));
    final online = await repository.todaySales(clock, recentLimit: 5);
    expect((online.count, online.totalCents, online.pendingCount), (4, 7500, 1));
    expect(online.recent.map((sale) => (sale.id, sale.pendingSync)), unorderedEquals([('s1', false), ('hoje', true)]));

    // Sem internet: o resumo guardado + a fila
    clock = DateTime(2026, 11, 16, 11);
    final offline = await repository.todaySales(clock, recentLimit: 5);
    expect((offline.count, offline.totalCents, offline.pendingCount), (4, 7500, 1));
    expect(offline.recent.firstWhere((sale) => sale.id == 's1').productNames, ['Feijão']);

    // No dia seguinte o resumo de ontem não vale: o dia começa do zero
    clock = DateTime(2026, 11, 17, 8);
    final nextDay = await repository.todaySales(clock, recentLimit: 5);
    expect((nextDay.count, nextDay.totalCents), (0, 0));
  });
}
