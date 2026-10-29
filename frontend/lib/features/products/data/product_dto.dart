import '../../../core/network/json_reader.dart';
import '../../../core/stock/stock_level.dart';
import '../domain/product.dart';

abstract final class ProductDto {
  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      id: json.requireString('id'),
      name: json.requireString('name'),
      photoUrl: json.optionalString('photoUrl'),
      thumbUrl: json.optionalString('thumbUrl'),
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
    return ProductPage(
      items: json.requireMapList('items').map(fromJson).toList(growable: false),
      total: json.requireInt('total'),
      stockCounts: counts is Map<String, dynamic> ? _countsFromJson(counts) : null,
      lowStockThreshold: json['lowStockThreshold'] is num ? (json['lowStockThreshold'] as num).toInt() : 0,
    );
  }

  static StockCounts _countsFromJson(Map<String, dynamic> counts) {
    int read(String key) => counts[key] is num ? (counts[key] as num).toInt() : 0;
    return StockCounts(all: read('all'), low: read('low'), out: read('out'));
  }

  static String filterQuery(StockFilter filter) => switch (filter) {
    StockFilter.all => 'all',
    StockFilter.low => 'low',
    StockFilter.out => 'out',
  };
}
