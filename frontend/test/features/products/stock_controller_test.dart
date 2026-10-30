import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/network/cancel_signal.dart';
import 'package:vendaqui/core/stock/stock_changes.dart';
import 'package:vendaqui/core/stock/stock_level.dart';
import 'package:vendaqui/features/products/domain/product.dart';
import 'package:vendaqui/features/products/presentation/controllers/stock_controller.dart';

import '../../support/fakes.dart';

/// Catálogo paginado como o servidor: contagens só na primeira página.
class _PagedRepository extends FakeProductsRepository {
  _PagedRepository(this.products);

  final List<Product> products;
  int listCalls = 0;
  Completer<void>? holdList;

  @override
  Future<ProductPage> list({
    required String search,
    required StockFilter filter,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  }) async {
    listCalls++;
    await holdList?.future;
    final matching = products.where((product) => filter.includes(product.stockLevel)).toList();
    return ProductPage(
      items: matching.skip(offset).take(limit).toList(),
      total: matching.length,
      stockCounts: offset == 0
          ? StockCounts(
              all: products.length,
              low: products.where((product) => product.stockLevel == StockLevel.low).length,
              out: products.where((product) => product.stockLevel == StockLevel.out).length,
            )
          : null,
      lowStockThreshold: 5,
    );
  }

  @override
  Future<Product> get(String id) async => products.firstWhere((product) => product.id == id);
}

Product _product(int index, StockLevel level) => Product(
  id: 'p$index',
  name: 'Produto $index',
  photoUrl: null,
  salePriceCents: 100,
  costPriceCents: 50,
  quantity: level == StockLevel.out ? 0 : 10,
  soldByWeight: false,
  stockLevel: level,
);

void main() {
  late StockChanges changes;
  late _PagedRepository repository;
  late StockController controller;

  setUp(() {
    changes = StockChanges();
    repository = _PagedRepository([for (var i = 0; i < 70; i++) _product(i, i < 5 ? StockLevel.out : StockLevel.ok)]);
  });

  tearDown(() => changes.dispose());

  Future<void> loadTwoPages(StockFilter filter) async {
    controller = StockController(repository, changes, initialFilter: filter);
    await controller.loadFirstPage();
    await controller.loadMore();
  }

  test('páginas seguintes mantêm as contagens da primeira', () async {
    await loadTwoPages(StockFilter.all);

    expect(controller.items, hasLength(60));
    expect(controller.counts, const StockCounts(all: 70, low: 0, out: 5));
    controller.dispose();
  });

  test('produto alterado é trocado no lugar, sem recarregar a lista', () async {
    await loadTwoPages(StockFilter.all);
    final callsBefore = repository.listCalls;
    repository.products[40] = _product(40, StockLevel.low);

    changes.notify(const ProductUpdated('p40'));
    await pumpEventQueue();

    expect(repository.listCalls, callsBefore);
    expect(controller.items, hasLength(60));
    expect(controller.items[40].stockLevel, StockLevel.low);
    expect(controller.counts, const StockCounts(all: 70, low: 1, out: 5));
    controller.dispose();
  });

  test('produto que sai do filtro atual some da lista', () async {
    await loadTwoPages(StockFilter.out);
    final callsBefore = repository.listCalls;
    repository.products[2] = _product(2, StockLevel.ok);

    changes.notify(const ProductUpdated('p2'));
    await pumpEventQueue();

    expect(repository.listCalls, callsBefore);
    expect(controller.items.map((product) => product.id), isNot(contains('p2')));
    expect(controller.counts.out, 4);
    expect(controller.hasMore, isFalse);
    controller.dispose();
  });

  test('resposta que chega depois de a tela fechar não lança', () async {
    await loadTwoPages(StockFilter.all);
    repository.holdList = Completer<void>();
    final pending = controller.loadMore();

    controller.dispose();
    repository.holdList!.complete();

    await expectLater(pending, completes);
  });
}
