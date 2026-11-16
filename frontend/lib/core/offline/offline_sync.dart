import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../network/api_codes.dart';
import '../network/app_failure.dart';
import '../network/json_map.dart';
import '../network/json_reader.dart';
import '../network/request_data.dart';
import 'local_database.dart';
import 'offline_status.dart';
import 'offline_store.dart';

/// Baixa produtos e clientes do servidor para a cópia local, página por página.
class OfflineSync {
  OfflineSync({required this._store, required this._status, this._flushPending, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final OfflineStore _store;
  final OfflineStatus _status;

  /// Envia a fila de alterações feitas sem internet; devolve se ela ficou vazia.
  final Future<bool> Function()? _flushPending;
  final DateTime Function() _clock;

  /// O maior tamanho de página que a API aceita: menos requisições para baixar tudo.
  static const pageSize = 100;

  /// Baixar tudo custa dados móveis: entre um download e outro, as listagens online já mantêm
  /// a cópia em dia página a página (o comerciante sai para o WhatsApp e volta muitas vezes por dia).
  static const minInterval = Duration(hours: 6);

  /// Depois de uma falha (sinal ruim), espera antes de baixar tudo de novo.
  static const retryAfterFailure = Duration(minutes: 30);

  Future<bool>? _running;
  DateTime? _failedAt;

  /// Devolve se a cópia foi atualizada. Sem internet, a cópia anterior continua valendo.
  /// [force] ignora o intervalo mínimo e a espera depois de uma falha.
  Future<bool> refresh({bool force = false}) {
    // Duas chamadas ao mesmo tempo (login e volta ao app) compartilham o mesmo download
    return _running ??= _refresh(force: force).whenComplete(() => _running = null);
  }

  Future<bool> _refresh({required bool force}) async {
    final now = _clock();
    final last = await _store.lastSyncedAt();
    final failedAt = _failedAt;
    if (!force && last != null && now.difference(last) < minInterval) return false;
    if (!force && failedAt != null && now.difference(failedAt) < retryAfterFailure) return false;

    // Com venda ainda na fila, o servidor não tem a baixa de estoque que a cópia já tem: trocar a cópia
    // agora faria o estoque "voltar" na tela até a venda ser enviada
    if (_flushPending case final flush? when !await flush()) return false;

    try {
      final startedAt = _clock();
      final products = await _downloadProducts();
      final customers = await _downloadAll(ApiPaths.customers, {'balance': 'all'}, _customerFromJson);
      await _store.replaceAll(
        products: products.rows,
        customers: customers,
        lowStockThreshold: products.lowStockThreshold,
        syncedAt: startedAt,
      );
      _failedAt = null;
      _status.markOnline();
      return true;
    } on AppFailure catch (failure) {
      _failedAt = _clock();
      if (kDebugMode) debugPrint('[OfflineSync] sincronização adiada: ${failure.runtimeType}');
      return false;
    }
  }

  Future<({List<LocalProductsCompanion> rows, int lowStockThreshold})> _downloadProducts() async {
    var lowStockThreshold = await _store.lowStockThreshold();
    final rows = await _downloadAll(
      ApiPaths.products,
      {'stockLevel': 'all'},
      _productFromJson,
      onPage: (page) {
        if (page['lowStockThreshold'] case final num threshold) lowStockThreshold = threshold.toInt();
      },
    );
    return (rows: rows, lowStockThreshold: lowStockThreshold);
  }

  Future<List<T>> _downloadAll<T>(
    String endpoint,
    Map<String, Object> filters,
    T Function(Map<String, dynamic> json) parseItem, {
    void Function(Map<String, dynamic> page)? onPage,
  }) async {
    // Por id: se algo for cadastrado no meio do download e empurrar a ordem, o repetido não duplica
    final byId = <String, T>{};
    var offset = 0;
    while (true) {
      final response = await requestData<({List<(String, T)> items, int total})>(
        endpoint: endpoint,
        params: {...filters, 'offset': offset, 'limit': pageSize},
        parse: (json) {
          final data = jsonMap(json);
          onPage?.call(data);
          return (
            items: [for (final item in data.requireMapList('items')) (item.requireString('id'), parseItem(item))],
            total: data.requireInt('total'),
          );
        },
      );
      final page = response.requireData();
      for (final (id, row) in page.items) {
        byId[id] = row;
      }
      offset += pageSize;
      if (page.items.isEmpty || offset >= page.total) return byId.values.toList(growable: false);
    }
  }

  static LocalProductsCompanion _productFromJson(Map<String, dynamic> json) {
    final name = json.requireString('name');
    return LocalProductsCompanion.insert(
      id: json.requireString('id'),
      name: name,
      searchKey: OfflineStore.searchKeyOf(name),
      photoUrl: Value(json.optionalString('photoUrl')),
      thumbUrl: Value(json.optionalString('thumbUrl')),
      salePriceCents: json.requireInt('salePriceCents'),
      costPriceCents: json.requireInt('costPriceCents'),
      quantity: json.requireDouble('quantity'),
      soldByWeight: json.optionalBool('soldByWeight'),
    );
  }

  static LocalCustomersCompanion _customerFromJson(Map<String, dynamic> json) {
    final name = json.requireString('name');
    return LocalCustomersCompanion.insert(
      id: json.requireString('id'),
      name: name,
      searchKey: OfflineStore.searchKeyOf(name),
      phone: json.requireString('phone'),
      balanceCents: json.requireInt('balanceCents'),
      creditDueDate: Value(json.optionalString('creditDueDate')),
    );
  }
}
