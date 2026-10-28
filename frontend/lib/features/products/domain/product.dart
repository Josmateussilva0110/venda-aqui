import 'package:flutter/foundation.dart';

import '../../../core/stock/stock_level.dart';

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.salePriceCents,
    required this.costPriceCents,
    required this.quantity,
    required this.soldByWeight,
    required this.stockLevel,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final int salePriceCents;
  final int costPriceCents;

  /// Unidades (inteiro) ou kg (até 3 casas) quando [soldByWeight].
  final double quantity;
  final bool soldByWeight;
  final StockLevel stockLevel;
}

/// Dados enviados no cadastro e na edição (o mesmo payload para os dois).
@immutable
class ProductInput {
  const ProductInput({
    required this.name,
    required this.salePriceCents,
    required this.costPriceCents,
    required this.quantity,
    required this.soldByWeight,
  });

  final String name;
  final int salePriceCents;
  final int costPriceCents;
  final double quantity;
  final bool soldByWeight;
}

/// Foto escolhida no aparelho, pronta para envio.
@immutable
class ProductPhoto {
  const ProductPhoto({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;

  static const maxBytes = 5 * 1024 * 1024;
  static const supportedTypes = {'image/jpeg', 'image/png', 'image/webp'};
}

enum StockFilter { all, low, out }

@immutable
class StockCounts {
  const StockCounts({required this.all, required this.low, required this.out});

  final int all;
  final int low;
  final int out;

  static const empty = StockCounts(all: 0, low: 0, out: 0);

  int of(StockFilter filter) => switch (filter) {
    StockFilter.all => all,
    StockFilter.low => low,
    StockFilter.out => out,
  };
}

@immutable
class ProductPage {
  const ProductPage({required this.items, required this.total, required this.stockCounts, required this.lowStockThreshold});

  final List<Product> items;
  final int total;
  final StockCounts stockCounts;
  final int lowStockThreshold;
}
