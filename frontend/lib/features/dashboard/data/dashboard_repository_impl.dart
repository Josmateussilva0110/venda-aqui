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
  static const _owingFilter = 'owing';

  @override
  Future<StockOverview> stockOverview({required int alertLimit}) async {
    final response = await requestData<StockOverview>(
      endpoint: ApiPaths.products,
      params: {'stockLevel': _attentionFilter, 'limit': alertLimit, 'offset': 0},
      parse: (json) => _overviewFromJson(jsonMap(json)),
    );
    return response.requireData();
  }

  // Contagem e soma do dia vêm no resumo do histórico; a primeira página traz as vendas mais recentes
  @override
  Future<TodaySales> todaySales(DateTime now, {required int recentLimit}) async {
    final from = DateTime(now.year, now.month, now.day);
    final until = DateTime(now.year, now.month, now.day + 1);
    final response = await requestData<TodaySales>(
      endpoint: ApiPaths.sales,
      params: {'from': from.toUtc().toIso8601String(), 'to': until.toUtc().toIso8601String(), 'limit': recentLimit, 'offset': 0},
      parse: (json) {
        final data = jsonMap(json);
        return TodaySales(
          count: data.requireInt('total'),
          totalCents: data.requireInt('totalCents'),
          recent: data.requireMapList('items').map(_recentSaleFromJson).toList(growable: false),
        );
      },
    );
    return response.requireData();
  }

  RecentSale _recentSaleFromJson(Map<String, dynamic> json) {
    final customer = json['customer'];
    return RecentSale(
      id: json.requireString('id'),
      productNames: json.requireMapList('items').map((item) => item.requireString('name')).toList(growable: false),
      createdAt: DateTime.parse(json.requireString('createdAt')).toLocal(),
      paymentMethod: json.requireString('paymentMethod'),
      totalCents: json.requireInt('totalCents'),
      customerName: customer is Map<String, dynamic> ? customer.optionalString('name') : null,
    );
  }

  // O resumo do fiado vem junto da lista de clientes; uma linha só basta para lê-lo
  @override
  Future<CreditOverview> creditOverview() async {
    final response = await requestData<CreditOverview>(
      endpoint: ApiPaths.customers,
      params: {'balance': _owingFilter, 'limit': 1, 'offset': 0},
      parse: (json) {
        final summary = jsonMap(json).requireMap('summary');
        return CreditOverview(owingCount: summary.requireInt('owingCount'), owedCents: summary.requireInt('owedCents'));
      },
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
