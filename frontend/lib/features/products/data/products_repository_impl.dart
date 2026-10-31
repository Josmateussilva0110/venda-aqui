import '../../../core/network/cancel_signal.dart';
import '../domain/product.dart';
import '../domain/products_repository.dart';
import 'products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<ProductPage> list({
    required String search,
    required StockFilter filter,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  }) {
    return _remote.list(search: search, filter: filter, offset: offset, limit: limit, cancel: cancel);
  }

  @override
  Future<Product> get(String id) => _remote.get(id);

  @override
  Future<String> create(ProductInput input) => _remote.create(input);

  @override
  Future<void> update(String id, ProductInput input) => _remote.update(id, input);

  @override
  Future<void> restock(String id, double quantity) => _remote.restock(id, quantity);

  @override
  Future<void> uploadPhoto(String id, ProductPhoto photo) => _remote.uploadPhoto(id, photo);
}
