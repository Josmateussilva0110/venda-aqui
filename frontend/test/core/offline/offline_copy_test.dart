import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/network/api_client.dart';
import 'package:vendaqui/core/network/app_failure.dart';
import 'package:vendaqui/core/network/cancel_signal.dart';
import 'package:vendaqui/core/offline/local_database.dart';
import 'package:vendaqui/core/offline/offline_reader.dart';
import 'package:vendaqui/core/offline/offline_status.dart';
import 'package:vendaqui/core/offline/offline_store.dart';
import 'package:vendaqui/core/offline/offline_sync.dart';
import 'package:vendaqui/core/stock/stock_level.dart';

import '../../support/fakes.dart';

/// Responde pela rota; devolver nulo simula queda de conexão.
class _RoutedAdapter implements HttpClientAdapter {
  _RoutedAdapter(this.route);

  (int, Map<String, Object?>)? Function(RequestOptions options) route;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final response = route(options);
    if (response == null) throw DioException.connectionError(requestOptions: options, reason: 'offline');
    final (status, body) = response;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> _productJson(int index, {double quantity = 10}) => {
  'id': 'p$index',
  'name': 'Produto ${index.toString().padLeft(3, '0')}',
  'salePriceCents': 500,
  'costPriceCents': 300,
  'quantity': quantity,
  'soldByWeight': false,
  'stockLevel': 'ok',
};

/// Página da API com o envelope padrão, recortada de [all] pelo offset/limit pedidos.
(int, Map<String, Object?>) _page(RequestOptions options, List<Map<String, Object?>> all, {Map<String, Object?> extra = const {}}) {
  final offset = int.parse('${options.queryParameters['offset']}');
  final limit = int.parse('${options.queryParameters['limit']}');
  return (
    200,
    {
      'success': true,
      'data': {'items': all.skip(offset).take(limit).toList(), 'total': all.length, ...extra},
    },
  );
}

LocalProductsCompanion _localProduct(String id, String name, double quantity) => LocalProductsCompanion.insert(
  id: id,
  name: name,
  searchKey: OfflineStore.searchKeyOf(name),
  photoUrl: const Value(null),
  thumbUrl: const Value(null),
  salePriceCents: 100,
  costPriceCents: 50,
  quantity: quantity,
  soldByWeight: false,
);

void main() {
  late OfflineStore store;
  late OfflineStatus status;
  late _RoutedAdapter adapter;

  setUp(() {
    store = memoryOfflineStore();
    status = OfflineStatus();
    adapter = _RoutedAdapter((_) => null);
    configureApi(Dio()..httpClientAdapter = adapter);
  });

  test('sincronização baixa todas as páginas, tira o que sumiu do servidor e não deixa cópia pela metade', () async {
    final products = [for (var index = 0; index < 150; index++) _productJson(index)];
    adapter.route = (options) => options.path == '/products'
        ? _page(options, products, extra: {'lowStockThreshold': 7})
        : _page(options, [
            {'id': 'c1', 'name': 'Ana', 'phone': '+5586999990000', 'balanceCents': 1500, 'creditDueDate': '2026-12-01'},
          ]);
    await store.upsertProducts([_localProduct('apagado', 'Produto removido no servidor', 3)]);

    final sync = OfflineSync(store: store, status: status);
    expect(await sync.refresh(), isTrue);

    final all = await store.products(search: '', level: null, offset: 0, limit: 500);
    expect(all.total, 150);
    expect(all.items.map((row) => row.id), isNot(contains('apagado')));
    expect(await store.lowStockThreshold(), 7);
    expect((await store.customer('c1'))?.creditDueDate, '2026-12-01');

    // A conexão cai na segunda página: a cópia anterior fica inteira, sem misturar com o download novo
    final grown = [...products, for (var index = 150; index < 260; index++) _productJson(index)];
    adapter.route = (options) {
      if (options.path != '/products') return _page(options, const []);
      return options.queryParameters['offset'] == 0 ? _page(options, grown) : null;
    };
    expect(await sync.refresh(force: true), isFalse);
    expect((await store.products(search: '', level: null, offset: 0, limit: 500)).total, 150);
  });

  test('busca local trata % como texto e separa baixo e esgotado com o limite do servidor', () async {
    await store.replaceAll(
      products: [_localProduct('a', 'Arroz 5kg', 0), _localProduct('b', 'Açúcar 100%', 3), _localProduct('c', 'Feijão', 20)],
      customers: const [],
      lowStockThreshold: 5,
      syncedAt: DateTime(2026, 11, 15, 9),
    );

    final percent = await store.products(search: '100%', level: null, offset: 0, limit: 10);
    expect(percent.items.map((row) => row.id), ['b']);
    expect((await store.products(search: '%', level: null, offset: 0, limit: 10)).total, 1);
    expect((await store.products(search: 'AÇÚ', level: null, offset: 0, limit: 10)).total, 1);

    expect((await store.products(search: '', level: StockLevel.out, offset: 0, limit: 10)).items.single.id, 'a');
    expect((await store.products(search: '', level: StockLevel.low, offset: 0, limit: 10)).items.single.id, 'b');
    expect(await store.productCounts(), (all: 3, low: 1, out: 1));
  });

  test('sem internet a leitura usa a cópia e não espera o servidor de novo logo em seguida', () async {
    var now = DateTime(2026, 11, 15, 10);
    final reader = OfflineReader(store, status, clock: () => now);
    var remoteCalls = 0;
    Future<String> offline() {
      remoteCalls++;
      return Future.error(const NetworkFailure());
    }

    Future<String> online() async {
      remoteCalls++;
      return 'servidor';
    }

    // Sem cópia completa, a falta de internet aparece como falha
    await expectLater(reader.read(remote: offline, local: (_) async => 'local'), throwsA(isA<NetworkFailure>()));
    expect(status.isOffline, isFalse);

    await store.replaceAll(products: const [], customers: const [], lowStockThreshold: 5, syncedAt: DateTime(2026, 11, 15, 9));
    now = now.add(OfflineReader.retryAfter);
    expect(await reader.read(remote: offline, local: (_) async => 'local'), 'local');
    expect(status.isOffline, isTrue);
    expect(status.savedAt, DateTime(2026, 11, 15, 9));

    // Logo depois da falha (sinal fraco), a próxima leitura vai direto à cópia, sem esperar o timeout
    remoteCalls = 0;
    expect(await reader.read(remote: online, local: (_) async => 'local'), 'local');
    expect(remoteCalls, 0);

    // Busca cancelada por outra não é falta de internet
    now = now.add(OfflineReader.retryAfter);
    final cancelled = CancelSignal()..cancel();
    await expectLater(reader.read(remote: offline, local: (_) async => 'local', cancel: cancelled), throwsA(isA<NetworkFailure>()));

    now = now.add(OfflineReader.retryAfter);
    expect(await reader.read(remote: online, local: (_) async => 'local'), 'servidor');
    expect(status.isOffline, isFalse);
  });

  test('entrar com outro comércio apaga a cópia do anterior', () async {
    await store.saveOwner((id: 'm1', name: 'Mercearia', phone: '+5586999990000'));
    await store.replaceAll(
      products: [_localProduct('a', 'Arroz', 10)],
      customers: const [],
      lowStockThreshold: 5,
      syncedAt: DateTime(2026, 11, 15, 9),
    );

    await store.saveOwner((id: 'm1', name: 'Mercearia', phone: '+5586999990000'));
    expect((await store.products(search: '', level: null, offset: 0, limit: 10)).total, 1);

    await store.saveOwner((id: 'm2', name: 'Padaria', phone: '+5586988880000'));
    expect((await store.products(search: '', level: null, offset: 0, limit: 10)).total, 0);
    expect(await store.lastSyncedAt(), isNull);
    expect((await store.owner())?.id, 'm2');
  });
}
