import 'dart:convert';

import '../../../core/network/api_codes.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../../../core/offline/offline_reader.dart';
import '../../../core/offline/offline_store.dart';
import '../../../core/notifications/reminder_notifier.dart';
import '../../../core/stock/stock_level.dart';
import '../../../core/utils/date_only.dart';
import '../domain/stock_overview.dart';

/// Lê o resumo do estoque pela lista de produtos filtrada em "attention" (baixo + esgotado).
/// Sem internet, só o estoque vem da cópia local: vendas do dia e fiado dependem do servidor.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._offline, this._pendingSales);

  final OfflineReader _offline;
  final PendingSalesSource _pendingSales;

  static const _todaySnapshotKey = 'today_sales';

  static const _attentionFilter = 'attention';
  static const _owingFilter = 'owing';

  @override
  Future<StockOverview> stockOverview({required int alertLimit}) {
    return _offline.read(
      remote: () async {
        final response = await requestData<StockOverview>(
          endpoint: ApiPaths.products,
          params: {'stockLevel': _attentionFilter, 'limit': alertLimit, 'offset': 0},
          parse: (json) => _overviewFromJson(jsonMap(json)),
        );
        return response.requireData();
      },
      local: (store) => _localOverview(store, alertLimit: alertLimit),
    );
  }

  Future<StockOverview> _localOverview(OfflineStore store, {required int alertLimit}) async {
    final threshold = await store.lowStockThreshold();
    final counts = await store.productCounts();
    final alerts = await store.productsNeedingAttention(limit: alertLimit);
    return StockOverview(
      totalProducts: counts.all,
      lowCount: counts.low,
      outCount: counts.out,
      alerts: [
        for (final row in alerts)
          StockAlert(
            productId: row.id,
            name: row.name,
            photoUrl: row.thumbUrl ?? row.photoUrl,
            quantity: row.quantity,
            soldByWeight: row.soldByWeight,
            level: StockLevel.of(row.quantity, lowThreshold: threshold),
          ),
      ],
    );
  }

  // Contagem e soma do dia vêm no resumo do histórico; a primeira página traz as vendas mais recentes.
  // Sem internet vale o último resumo do dia guardado no aparelho. Nos dois casos entram as vendas que
  // ainda estão na fila: o servidor não as tem, mas elas aconteceram no balcão
  @override
  Future<TodaySales> todaySales(DateTime now, {required int recentLimit}) async {
    final from = DateTime(now.year, now.month, now.day);
    final until = DateTime(now.year, now.month, now.day + 1);
    final day = DateOnly.toApi(from);
    final server = await _offline.read(
      remote: () async {
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
      },
      save: (store, sales) => store.saveSnapshot(_todaySnapshotKey, jsonEncode(_snapshotToJson(day, sales))),
      // Resumo de outro dia não serve: sem resumo de hoje, o dia começa do zero (mais o que está na fila)
      local: (store) async => _snapshotFromJson(await store.snapshot(_todaySnapshotKey), day) ?? TodaySales.empty,
    );
    return server.withPending(await _pendingSales(from, until), recentLimit: recentLimit);
  }

  static Map<String, Object?> _snapshotToJson(String day, TodaySales sales) => {
    'day': day,
    'count': sales.count,
    'totalCents': sales.totalCents,
    'recent': [
      for (final sale in sales.recent)
        {
          'id': sale.id,
          'items': [
            for (final name in sale.productNames) {'name': name},
          ],
          'createdAt': sale.createdAt.toUtc().toIso8601String(),
          'paymentMethod': sale.paymentMethod,
          'totalCents': sale.totalCents,
          if (sale.customerName != null) 'customer': {'name': sale.customerName},
        },
    ],
  };

  // Mesmo formato da API nas vendas recentes, para reaproveitar a leitura; dado ilegível vira "sem resumo"
  TodaySales? _snapshotFromJson(String? raw, String day) {
    if (raw == null) return null;
    try {
      final data = jsonMap(jsonDecode(raw));
      if (data['day'] != day) return null;
      return TodaySales(
        count: data.requireInt('count'),
        totalCents: data.requireInt('totalCents'),
        recent: data.requireMapList('recent').map(_recentSaleFromJson).toList(growable: false),
      );
    } on Object {
      return null;
    }
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
        return CreditOverview(
          owingCount: summary.requireInt('owingCount'),
          owedCents: summary.requireInt('owedCents'),
          reminders: ReminderSchedule.fromSummaryJson(summary['reminders']),
        );
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
