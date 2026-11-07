import '../../../core/network/cancel_signal.dart';
import '../domain/sale.dart';
import '../domain/sales_repository.dart';
import 'catalog_remote_data_source.dart';
import 'sales_remote_data_source.dart';

class SalesRepositoryImpl implements SalesRepository {
  SalesRepositoryImpl(this._catalog, this._sales, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final CatalogRemoteDataSource _catalog;
  final SalesRemoteDataSource _sales;
  final DateTime Function() _clock;

  @override
  Future<CatalogPage> catalog({required String search, required int offset, required int limit, CancelSignal? cancel}) {
    return _catalog.list(search: search, offset: offset, limit: limit, cancel: cancel);
  }

  // A API devolve só id e total; o resto o app já tem. Evita uma segunda requisição só para confirmar
  @override
  Future<Sale> register(SaleInput input) async {
    final saved = await _sales.register(input);
    return _saleFrom(input, id: saved.id, totalCents: saved.totalCents, createdAt: _clock());
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

  Sale _saleFrom(SaleInput input, {required String id, required int totalCents, required DateTime createdAt, DateTime? editedAt}) {
    return Sale(
      id: id,
      createdAt: createdAt,
      editedAt: editedAt,
      items: input.items,
      method: input.method,
      totalCents: totalCents,
      customer: input.method == PaymentMethod.credit ? input.customer : null,
    );
  }
}
