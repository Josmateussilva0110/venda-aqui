import '../../../core/network/api_codes.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../../../core/stock/stock_level.dart';
import '../domain/stock_overview.dart';

/// Lê o resumo do estoque pela lista de produtos filtrada em "attention" (baixo + esgotado).
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl();

  static const _attentionFilter = 'attention';

  @override
  Future<StockOverview> stockOverview({required int alertLimit}) async {
    final response = await requestData<StockOverview>(
      endpoint: ApiPaths.products,
      params: {'stockLevel': _attentionFilter, 'limit': alertLimit, 'offset': 0},
      parse: (json) => _overviewFromJson(jsonMap(json)),
    );
    return response.requireData();
  }

  StockOverview _overviewFromJson(Map<String, dynamic> data) {
    final counts = data.requireMap('stockCounts');
    return StockOverview(
      totalProducts: counts.requireInt('all'),
      lowCount: counts.requireInt('low'),
      outCount: counts.requireInt('out'),
      alerts: data.requireMapList('items').map(_alertFromJson).toList(growable: false),
    );
  }

  StockAlert _alertFromJson(Map<String, dynamic> json) {
    return StockAlert(
      productId: json.requireString('id'),
      name: json.requireString('name'),
      // O início só mostra miniaturas: a foto inteira fica para quando não há miniatura
      photoUrl: json.optionalString('thumbUrl') ?? json.optionalString('photoUrl'),
      quantity: json.requireDouble('quantity'),
      soldByWeight: json.optionalBool('soldByWeight'),
      level: StockLevel.parse(json.optionalString('stockLevel')),
    );
  }
}
