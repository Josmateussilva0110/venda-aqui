import '../../../core/network/cancel_signal.dart';
import 'product.dart';

/// Contrato de produtos. Busca, filtro e paginação são feitos pelo servidor.
abstract interface class ProductsRepository {
  Future<ProductPage> list({
    required String search,
    required StockFilter filter,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  });

  Future<Product> get(String id);

  Future<String> create(ProductInput input);

  Future<void> update(String id, ProductInput input);

  /// Soma [quantity] ao estoque; o novo total é calculado no servidor.
  Future<void> restock(String id, double quantity);

  Future<void> uploadPhoto(String id, ProductPhoto photo);
}
