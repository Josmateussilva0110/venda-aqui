import 'package:drift/drift.dart' show Value;

import '../../../core/network/cancel_signal.dart';
import '../../../core/offline/local_database.dart';
import '../../../core/offline/offline_reader.dart';
import '../../../core/offline/offline_store.dart';
import '../../../core/offline/offline_writer.dart';
import '../../../core/stock/stock_level.dart';
import '../domain/product.dart';
import '../domain/products_repository.dart';
import 'pending_restock_sender.dart';
import 'products_remote_data_source.dart';

/// Leituras vão ao servidor e, sem internet, à cópia local. Sem internet, só a reposição vai para a fila;
/// cadastro, edição, foto e exclusão continuam só online.
class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remote, this._offline, this._writer);

  final ProductsRemoteDataSource _remote;
  final OfflineReader _offline;
  final OfflineWriter _writer;

  @override
  Future<ProductPage> list({
    required String search,
    required StockFilter filter,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  }) {
    return _offline.read(
      cancel: cancel,
      remote: () => _remote.list(search: search, filter: filter, offset: offset, limit: limit, cancel: cancel),
      save: (store, page) => store.upsertProducts(page.items.map(_toLocal).toList(), lowStockThreshold: page.lowStockThreshold),
      local: (store) => _localPage(store, search: search, filter: filter, offset: offset, limit: limit),
    );
  }

  @override
  Future<Product> get(String id) {
    return _offline.read(
      remote: () => _remote.get(id),
      save: (store, product) => store.upsertProducts([_toLocal(product)]),
      local: (store) async {
        final row = await store.product(id);
        return row == null ? null : _fromLocal(row, await store.lowStockThreshold());
      },
    );
  }

  @override
  Future<String> create(ProductInput input) => _remote.create(input);

  @override
  Future<void> update(String id, ProductInput input) => _remote.update(id, input);

  @override
  Future<void> delete(String id) async {
    await _remote.delete(id);
    await _offline.store.deleteProduct(id);
  }

  // Reposição é só somar: feita sem internet não conflita com nada e sobe quando a conexão voltar
  @override
  Future<SyncState> restock(String id, double quantity) async {
    final product = await _offline.store.product(id);
    final write = await _writer.write(
      kind: PendingRestockSender.kind,
      online: (clientId, budget) => _remote.restock(id, quantity, clientId: clientId, cancel: budget),
      queued: (clientId, _) => PendingRestockSender.payload(
        productId: id,
        body: ProductsRemoteDataSource.restockBody(quantity, clientId: clientId),
        productName: product?.name ?? '',
        soldByWeight: product?.soldByWeight ?? false,
      ),
      localEffects: (store) => store.applyRestock(productId: id, quantity: quantity),
    );
    return write.state;
  }

  @override
  Future<void> uploadPhoto(String id, ProductPhoto photo) => _remote.uploadPhoto(id, photo);

  Future<ProductPage> _localPage(
    OfflineStore store, {
    required String search,
    required StockFilter filter,
    required int offset,
    required int limit,
  }) async {
    final level = switch (filter) {
      StockFilter.all => null,
      StockFilter.low => StockLevel.low,
      StockFilter.out => StockLevel.out,
    };
    final threshold = await store.lowStockThreshold();
    final page = await store.products(search: search, level: level, offset: offset, limit: limit);
    // Como no servidor, as contagens só acompanham a primeira página
    final counts = offset == 0 ? await store.productCounts() : null;
    return ProductPage(
      items: page.items.map((row) => _fromLocal(row, threshold)).toList(growable: false),
      total: page.total,
      stockCounts: counts == null ? null : StockCounts(all: counts.all, low: counts.low, out: counts.out),
      lowStockThreshold: threshold,
    );
  }

  static Product _fromLocal(LocalProduct row, int lowThreshold) {
    return Product(
      id: row.id,
      name: row.name,
      photoUrl: row.photoUrl,
      thumbUrl: row.thumbUrl,
      salePriceCents: row.salePriceCents,
      costPriceCents: row.costPriceCents,
      quantity: row.quantity,
      soldByWeight: row.soldByWeight,
      stockLevel: StockLevel.of(row.quantity, lowThreshold: lowThreshold),
    );
  }

  static LocalProductsCompanion _toLocal(Product product) {
    return LocalProductsCompanion.insert(
      id: product.id,
      name: product.name,
      searchKey: OfflineStore.searchKeyOf(product.name),
      photoUrl: Value(product.photoUrl),
      thumbUrl: Value(product.thumbUrl),
      salePriceCents: product.salePriceCents,
      costPriceCents: product.costPriceCents,
      quantity: product.quantity,
      soldByWeight: product.soldByWeight,
    );
  }
}
