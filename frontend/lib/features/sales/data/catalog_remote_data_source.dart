import '../../../core/network/api_codes.dart';
import '../../../core/network/cancel_signal.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../domain/sale.dart';

/// Catálogo da venda a partir da listagem de produtos da API (busca e paginação no servidor).
class CatalogRemoteDataSource {
  const CatalogRemoteDataSource();

  static const _allStockLevels = 'all';

  Future<CatalogPage> list({required String search, required int offset, required int limit, CancelSignal? cancel}) async {
    final response = await requestData<CatalogPage>(
      endpoint: ApiPaths.products,
      params: {'search': search, 'stockLevel': _allStockLevels, 'offset': offset, 'limit': limit},
      cancelToken: cancel?.token,
      parse: (json) {
        final data = jsonMap(json);
        return CatalogPage(
          items: data.requireMapList('items').map(_productFromJson).toList(growable: false),
          total: data.requireInt('total'),
        );
      },
    );
    return response.requireData();
  }

  CatalogProduct _productFromJson(Map<String, dynamic> json) {
    return CatalogProduct(
      id: json.requireString('id'),
      name: json.requireString('name'),
      salePriceCents: json.requireInt('salePriceCents'),
      quantity: json.requireDouble('quantity'),
      soldByWeight: json.optionalBool('soldByWeight'),
      // A grade mostra miniaturas: a foto inteira só quando não há miniatura
      photoUrl: json.optionalString('thumbUrl') ?? json.optionalString('photoUrl'),
    );
  }
}
