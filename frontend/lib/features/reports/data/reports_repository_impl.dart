import '../../../core/network/api_codes.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../domain/sales_report.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl();

  @override
  Future<SalesReport> salesReport({required DateTime from, required DateTime to}) async {
    // Dias inteiros no fuso do aparelho; o fim é exclusivo (meia-noite do dia seguinte)
    final start = DateTime(from.year, from.month, from.day);
    final until = DateTime(to.year, to.month, to.day + 1);
    final response = await requestData<SalesReport>(
      endpoint: ApiPaths.salesReport,
      params: {'from': start.toUtc().toIso8601String(), 'to': until.toUtc().toIso8601String()},
      parse: (json) => _reportFromJson(jsonMap(json)),
    );
    return response.requireData();
  }

  SalesReport _reportFromJson(Map<String, dynamic> json) {
    return SalesReport(
      saleCount: json.requireInt('saleCount'),
      revenueCents: json.requireInt('revenueCents'),
      costCents: json.requireInt('costCents'),
      profitCents: json.requireInt('profitCents'),
      ranking: json.requireMapList('ranking').map(_rankingFromJson).toList(growable: false),
    );
  }

  ReportRankingItem _rankingFromJson(Map<String, dynamic> json) {
    return ReportRankingItem(
      name: json.requireString('name'),
      soldByWeight: json.optionalBool('soldByWeight'),
      quantity: json.requireDouble('quantity'),
      revenueCents: json.requireInt('revenueCents'),
      profitCents: json.requireInt('profitCents'),
    );
  }
}
