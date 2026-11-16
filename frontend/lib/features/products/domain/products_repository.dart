import '../../../core/network/cancel_signal.dart';
import '../../../core/offline/sync_state.dart';
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

  /// Vendas já registradas guardam nome e preço do item e não são afetadas.
  Future<void> delete(String id);

  /// Soma [quantity] ao estoque; o novo total é calculado no servidor. Sem internet a reposição fica
  /// guardada no aparelho ([SyncState.pending]) e sobe sozinha depois.
  Future<SyncState> restock(String id, double quantity);

  Future<void> uploadPhoto(String id, ProductPhoto photo);
}
