import '../../../core/network/cancel_signal.dart';
import 'sale.dart';

/// Contrato de vendas. Busca, filtro e paginação são responsabilidade de quem implementa (o servidor).
abstract interface class SalesRepository {
  /// Produtos para vender, em ordem alfabética e paginados.
  Future<CatalogPage> catalog({required String search, required int offset, required int limit, CancelSignal? cancel});

  Future<Sale> register(SaleInput input);

  /// Vendas do filtro, da mais recente para a mais antiga, paginadas.
  Future<SaleHistoryPage> history(SaleFilter filter, {required int offset, required int limit, CancelSignal? cancel});

  Future<Sale> get(String id);

  /// [createdAt] é o da venda original: editar não muda a data da venda.
  Future<Sale> update(String id, SaleInput input, {required DateTime createdAt});
}
