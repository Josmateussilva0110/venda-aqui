import '../../../core/network/json_reader.dart';
import '../../../core/stock/stock_level.dart';
import '../domain/product.dart';

abstract final class ProductDto {
  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      id: json.requireString('id'),
      name: json.requireString('name'),
      photoUrl: json.optionalString('photoUrl'),
      salePriceCents: json.requireInt('salePriceCents'),
      costPriceCents: json.requireInt('costPriceCents'),
      quantity: json.requireDouble('quantity'),
      soldByWeight: json.optionalBool('soldByWeight'),
      stockLevel: StockLevel.parse(json.optionalString('stockLevel')),
    );
  }

  static Map<String, Object> toJson(ProductInput input) => {
    'name': input.name,
    'salePriceCents': input.salePriceCents,
    'costPriceCents': input.costPriceCents,
    'quantity': input.quantity,
    'soldByWeight': input.soldByWeight,
  };

  static ProductPage pageFromJson(Map<String, dynamic> json) {
    final counts = json['stockCounts'];
    final countsMap = counts is Map<String, dynamic> ? counts : const <String, dynamic>{};
    return ProductPage(
      items: json.requireMapList('items').map(fromJson).toList(growable: false),
      total: json.requireInt('total'),
      stockCounts: StockCounts(
        all: countsMap['all'] is num ? (countsMap['all'] as num).toInt() : 0,
        low: countsMap['low'] is num ? (countsMap['low'] as num).toInt() : 0,
        out: countsMap['out'] is num ? (countsMap['out'] as num).toInt() : 0,
      ),
      lowStockThreshold: json['lowStockThreshold'] is num ? (json['lowStockThreshold'] as num).toInt() : 0,
    );
  }

  static String filterQuery(StockFilter filter) => switch (filter) {
    StockFilter.all => 'all',
    StockFilter.low => 'low',
    StockFilter.out => 'out',
  };
}
