import 'package:flutter/foundation.dart';

import '../../../core/stock/stock_level.dart';

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.photoUrl,
    this.thumbUrl,
    required this.salePriceCents,
    required this.costPriceCents,
    required this.quantity,
    required this.soldByWeight,
    required this.stockLevel,
  });

  final String id;
  final String name;
  final String? photoUrl;

  /// Miniatura da foto para listas; produtos com foto antiga não têm e usam a foto inteira.
  final String? thumbUrl;
  final int salePriceCents;
  final int costPriceCents;

  /// Unidades (inteiro) ou kg (até 3 casas) quando [soldByWeight].
  final double quantity;
  final bool soldByWeight;
  final StockLevel stockLevel;

  String? get listPhotoUrl => thumbUrl ?? photoUrl;
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
  const ProductPhoto({required this.bytes, required this.contentType, this.thumbBytes});

  final Uint8List bytes;
  final String contentType;

  /// Miniatura em JPEG para as listas. Nula se não deu para gerar no aparelho: a foto vai mesmo assim.
  final Uint8List? thumbBytes;

  static const thumbContentType = 'image/jpeg';

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

  /// Move um produto de uma situação para outra (o total não muda).
  StockCounts moved(StockLevel from, StockLevel to) {
    if (from == to) return this;
    int delta(StockLevel level) => (level == to ? 1 : 0) - (level == from ? 1 : 0);
    return StockCounts(all: all, low: low + delta(StockLevel.low), out: out + delta(StockLevel.out));
  }

  @override
  bool operator ==(Object other) => other is StockCounts && other.all == all && other.low == low && other.out == out;

  @override
  int get hashCode => Object.hash(all, low, out);
}

extension StockFilterMatch on StockFilter {
  /// Se um produto nessa situação aparece com este filtro (o mesmo critério do servidor).
  bool includes(StockLevel level) => switch (this) {
    StockFilter.all => true,
    StockFilter.low => level == StockLevel.low,
    StockFilter.out => level == StockLevel.out,
  };
}

@immutable
class ProductPage {
  const ProductPage({required this.items, required this.total, required this.stockCounts, required this.lowStockThreshold});

  final List<Product> items;
  final int total;

  /// Só vem na primeira página; as seguintes mantêm as contagens que o app já tem.
  final StockCounts? stockCounts;
  final int lowStockThreshold;
}
