import 'package:flutter/foundation.dart';

import '../../../core/stock/stock_level.dart';

/// Produto que precisa de reposição, como mostrado no início.
@immutable
class StockAlert {
  const StockAlert({
    required this.productId,
    required this.name,
    required this.photoUrl,
    required this.quantity,
    required this.soldByWeight,
    required this.level,
  });

  final String productId;
  final String name;
  final String? photoUrl;
  final double quantity;
  final bool soldByWeight;
  final StockLevel level;
}

@immutable
class StockOverview {
  const StockOverview({required this.totalProducts, required this.lowCount, required this.outCount, required this.alerts});

  final int totalProducts;
  final int lowCount;
  final int outCount;

  /// Os mais urgentes primeiro (menor estoque), já ordenados pelo servidor.
  final List<StockAlert> alerts;
}

abstract interface class DashboardRepository {
  Future<StockOverview> stockOverview({required int alertLimit});
}
