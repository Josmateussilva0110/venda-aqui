import 'package:flutter/foundation.dart';

import '../../../core/notifications/reminder_notifier.dart';

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
  const CreditOverview({required this.owingCount, required this.owedCents, this.reminders});

  final int owingCount;
  final int owedCents;

  /// Lembretes pendentes e o próximo aviso; nulo com os lembretes desligados.
  final ReminderSchedule? reminders;
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
    this.pendingSync = false,
  });

  final String id;
  final List<String> productNames;
  final DateTime createdAt;

  /// Valor da API (`cash`, `pix`, `card`, `credit`); a tela traduz.
  final String paymentMethod;
  final int totalCents;

  /// Só no fiado.
  final String? customerName;

  /// Feita sem internet e ainda na fila: o servidor ainda não a tem (não abre o detalhe da venda).
  final bool pendingSync;
}

/// Vendas de hoje: contagem e soma do dia inteiro (servidor) e as mais recentes.
@immutable
class TodaySales {
  const TodaySales({required this.count, required this.totalCents, this.recent = const [], this.pendingCount = 0});

  final int count;
  final int totalCents;

  /// Da mais recente para a mais antiga.
  final List<RecentSale> recent;

  /// Quantas das vendas do dia ainda estão na fila do aparelho (já somadas em [count] e [totalCents]).
  final int pendingCount;

  static const empty = TodaySales(count: 0, totalCents: 0);

  /// Soma as vendas de hoje que ainda estão na fila: o servidor não as tem, mas elas aconteceram.
  TodaySales withPending(List<RecentSale> pending, {required int recentLimit}) {
    if (pending.isEmpty) return this;
    final merged = [...pending, ...recent]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return TodaySales(
      count: count + pending.length,
      totalCents: totalCents + pending.fold(0, (sum, sale) => sum + sale.totalCents),
      recent: merged.take(recentLimit).toList(growable: false),
      pendingCount: pending.length,
    );
  }
}

/// Vendas feitas sem internet entre [from] e [until] que ainda estão na fila. Vem de fora (a fila é da
/// feature de vendas): o início só as soma ao dia.
typedef PendingSalesSource = Future<List<RecentSale>> Function(DateTime from, DateTime until);

abstract interface class DashboardRepository {
  Future<StockOverview> stockOverview({required int alertLimit});

  /// [now] define o "hoje" no fuso do aparelho; [recentLimit] é quantas vendas vêm na lista.
  Future<TodaySales> todaySales(DateTime now, {required int recentLimit});

  Future<CreditOverview> creditOverview();
}
