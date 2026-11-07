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

/// Fiado do comércio: quantos clientes devem e quanto há para receber.
@immutable
class CreditOverview {
  const CreditOverview({required this.owingCount, required this.owedCents});

  final int owingCount;
  final int owedCents;
}

/// Venda recente como aparece no início: produtos, hora, forma de pagamento e total.
@immutable
class RecentSale {
  const RecentSale({
    required this.id,
    required this.productNames,
    required this.createdAt,
    required this.paymentMethod,
    required this.totalCents,
    this.customerName,
  });

  final String id;
  final List<String> productNames;
  final DateTime createdAt;

  /// Valor da API (`cash`, `pix`, `card`, `credit`); a tela traduz.
  final String paymentMethod;
  final int totalCents;

  /// Só no fiado.
  final String? customerName;
}

/// Vendas de hoje: contagem e soma do dia inteiro (servidor) e as mais recentes.
@immutable
class TodaySales {
  const TodaySales({required this.count, required this.totalCents, this.recent = const []});

  final int count;
  final int totalCents;

  /// Da mais recente para a mais antiga.
  final List<RecentSale> recent;
}

abstract interface class DashboardRepository {
  Future<StockOverview> stockOverview({required int alertLimit});

  /// [now] define o "hoje" no fuso do aparelho; [recentLimit] é quantas vendas vêm na lista.
  Future<TodaySales> todaySales(DateTime now, {required int recentLimit});

  Future<CreditOverview> creditOverview();
}
