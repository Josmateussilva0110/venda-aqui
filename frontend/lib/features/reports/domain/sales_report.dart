import 'package:flutter/foundation.dart';

/// Produto no ranking de lucro, já ordenado pelo servidor.
@immutable
class ReportRankingItem {
  const ReportRankingItem({
    required this.name,
    required this.soldByWeight,
    required this.quantity,
    required this.revenueCents,
    required this.profitCents,
  });

  final String name;
  final bool soldByWeight;
  final double quantity;
  final int revenueCents;
  final int profitCents;
}

/// Lucro do período, calculado pelo servidor com o custo guardado em cada venda.
@immutable
class SalesReport {
  const SalesReport({
    required this.saleCount,
    required this.revenueCents,
    required this.costCents,
    required this.profitCents,
    required this.ranking,
  });

  final int saleCount;
  final int revenueCents;
  final int costCents;
  final int profitCents;
  final List<ReportRankingItem> ranking;

  /// Margem em % sobre o total vendido; nula sem vendas.
  int? get marginPercent => revenueCents == 0 ? null : (profitCents * 100 / revenueCents).round();
}

abstract interface class ReportsRepository {
  /// Período por dia, inclusivo, no fuso do aparelho.
  Future<SalesReport> salesReport({required DateTime from, required DateTime to});
}
