import '../../../core/network/cancel_signal.dart';
import '../../../core/offline/offline_reader.dart';
import '../../../core/offline/offline_store.dart';
import '../../../core/offline/offline_writer.dart';
import '../domain/sale.dart';
import '../domain/sales_repository.dart';
import 'catalog_remote_data_source.dart';
import 'pending_sale_sender.dart';
import 'sale_dto.dart';
import 'sales_remote_data_source.dart';

class SalesRepositoryImpl implements SalesRepository {
  SalesRepositoryImpl(this._catalog, this._sales, this._offline, this._writer, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final CatalogRemoteDataSource _catalog;
  final SalesRemoteDataSource _sales;
  final OfflineReader _offline;
  final OfflineWriter _writer;
  final DateTime Function() _clock;

  // Sem internet, o catálogo vem da cópia local (a listagem online já é guardada pelo estoque e pela sincronização)
  @override
  Future<CatalogPage> catalog({required String search, required int offset, required int limit, CancelSignal? cancel}) {
    return _offline.read(
      cancel: cancel,
      remote: () => _catalog.list(search: search, offset: offset, limit: limit, cancel: cancel),
      local: (store) => _localCatalog(store, search: search, offset: offset, limit: limit),
    );
  }

  // A API devolve só id e total; o resto o app já tem. Evita uma segunda requisição só para confirmar.
  // Sem internet a venda não se perde: vai para a fila com a hora do balcão e sobe quando a conexão voltar
  @override
  Future<Sale> register(SaleInput input) async {
    final localTotal = input.items.fold(0, (sum, item) => sum + item.subtotalCents);
    final customerId = input.method == PaymentMethod.credit ? input.customer?.id : null;
    final write = await _writer.write(
      kind: PendingSaleSender.kind,
      online: (clientId, budget) => _sales.register(input, clientId: clientId, cancel: budget),
      queued: (clientId, soldAt) => PendingSaleSender.payload(
        body: SaleDto.toJson(input, clientId: clientId, soldAt: soldAt),
        input: input,
        totalCents: localTotal,
      ),
      localEffects: (store) => store.applyOfflineSale(
        items: [
          for (final item in input.items)
            if (item.productId case final productId?) (productId: productId, quantity: item.quantity),
        ],
        customerId: customerId,
        totalCents: localTotal,
      ),
    );
    final saved = write.value;
    if (saved == null) {
      return _saleFrom(input, id: write.clientId, totalCents: localTotal, createdAt: write.at, pendingSync: true);
    }
    return _saleFrom(input, id: saved.id, totalCents: saved.totalCents, createdAt: write.at);
  }

  @override
  Future<SaleHistoryPage> history(SaleFilter filter, {required int offset, required int limit, CancelSignal? cancel}) {
    return _sales.history(filter, offset: offset, limit: limit, cancel: cancel);
  }

  @override
  Future<Sale> get(String id) => _sales.get(id);

  /// A edição não acrescenta produtos, então os preços do app são os da época (os mesmos que o servidor mantém).
  @override
  Future<Sale> update(String id, SaleInput input, {required DateTime createdAt}) async {
    final saved = await _sales.update(id, input);
    return _saleFrom(input, id: saved.id, totalCents: saved.totalCents, createdAt: createdAt, editedAt: _clock());
  }

  Future<CatalogPage> _localCatalog(OfflineStore store, {required String search, required int offset, required int limit}) async {
    final page = await store.products(search: search, level: null, offset: offset, limit: limit);
    return CatalogPage(
      items: [
        for (final row in page.items)
          CatalogProduct(
            id: row.id,
            name: row.name,
            salePriceCents: row.salePriceCents,
            quantity: row.quantity,
            soldByWeight: row.soldByWeight,
            photoUrl: row.thumbUrl ?? row.photoUrl,
          ),
      ],
      total: page.total,
    );
  }

  Sale _saleFrom(
    SaleInput input, {
    required String id,
    required int totalCents,
    required DateTime createdAt,
    DateTime? editedAt,
    bool pendingSync = false,
  }) {
    return Sale(
      id: id,
      createdAt: createdAt,
      editedAt: editedAt,
      pendingSync: pendingSync,
      items: input.items,
      method: input.method,
      totalCents: totalCents,
      customer: input.method == PaymentMethod.credit ? input.customer : null,
    );
  }
}
