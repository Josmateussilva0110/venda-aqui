import 'dart:convert';

import 'package:drift/drift.dart';

import '../stock/stock_level.dart';
import 'local_database.dart';

typedef LocalPage<T> = ({List<T> items, int total});

typedef LocalOwner = ({String id, String name, String phone});

/// Consultas à cópia local, com a mesma busca, filtro e ordem do servidor. Só são usadas sem internet:
/// online, quem filtra e pagina continua sendo o backend.
class OfflineStore {
  OfflineStore(this._db);

  final LocalDatabase _db;

  static const _lastSyncedAtKey = 'last_synced_at';
  static const _lowStockThresholdKey = 'low_stock_threshold';
  static const _ownerKey = 'owner';

  /// O mesmo do backend; só vale até a primeira sincronização trazer o valor de lá.
  static const _defaultLowStockThreshold = 5;

  static final _phoneSearch = RegExp(r'^[\d\s()+-]+$');

  // ---------- Sincronização ----------

  /// Troca a cópia inteira de uma vez: o que foi apagado no servidor some daqui também.
  /// Numa transação, para uma falha no meio não deixar a cópia pela metade.
  Future<void> replaceAll({
    required List<LocalProductsCompanion> products,
    required List<LocalCustomersCompanion> customers,
    required int lowStockThreshold,
    required DateTime syncedAt,
  }) {
    return _db.transaction(() async {
      await _db.delete(_db.localProducts).go();
      await _db.delete(_db.localCustomers).go();
      await _db.batch((batch) {
        batch.insertAll(_db.localProducts, products, mode: InsertMode.insertOrReplace);
        batch.insertAll(_db.localCustomers, customers, mode: InsertMode.insertOrReplace);
      });
      await _setMark(_lowStockThresholdKey, '$lowStockThreshold');
      await _setMark(_lastSyncedAtKey, syncedAt.toUtc().toIso8601String());
    });
  }

  /// Atualiza a cópia com o que acabou de chegar numa listagem online, sem esperar a próxima sincronização.
  Future<void> upsertProducts(List<LocalProductsCompanion> products, {int? lowStockThreshold}) {
    return _db.transaction(() async {
      await _db.batch((batch) => batch.insertAll(_db.localProducts, products, mode: InsertMode.insertOrReplace));
      if (lowStockThreshold != null) await _setMark(_lowStockThresholdKey, '$lowStockThreshold');
    });
  }

  Future<void> upsertCustomers(List<LocalCustomersCompanion> customers) {
    return _db.batch((batch) => batch.insertAll(_db.localCustomers, customers, mode: InsertMode.insertOrReplace));
  }

  Future<void> deleteProduct(String id) => (_db.delete(_db.localProducts)..where((row) => row.id.equals(id))).go();

  Future<void> deleteCustomer(String id) => (_db.delete(_db.localCustomers)..where((row) => row.id.equals(id))).go();

  Future<void> clear() => _db.clearCopy();

  Future<DateTime?> lastSyncedAt() async {
    final raw = await _mark(_lastSyncedAtKey);
    return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  }

  Future<int> lowStockThreshold() async {
    final raw = await _mark(_lowStockThresholdKey);
    return int.tryParse(raw ?? '') ?? _defaultLowStockThreshold;
  }

  // ---------- Dono da cópia ----------

  /// Quem está logado (id, nome e telefone, nada de token), para abrir o app sem internet.
  /// Se for outro comércio, a cópia anterior é apagada antes: dados de uma conta nunca aparecem na outra.
  /// A fila de alterações do comércio anterior fica guardada, separada pelo dono.
  Future<void> saveOwner(LocalOwner owner) {
    return _db.transaction(() async {
      final current = await this.owner();
      if (current != null && current.id != owner.id) await _db.clearCopy();
      await _setMark(_ownerKey, jsonEncode({'id': owner.id, 'name': owner.name, 'phone': owner.phone}));
    });
  }

  Future<LocalOwner?> owner() async {
    final raw = await _mark(_ownerKey);
    if (raw == null) return null;
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) return null;
    final (id, name, phone) = (json['id'], json['name'], json['phone']);
    return id is String && name is String && phone is String ? (id: id, name: name, phone: phone) : null;
  }

  // ---------- Produtos ----------

  /// [level] nulo traz todos. "Baixo" e "esgotado" seguem o critério do servidor ([StockLevel.of]).
  Future<LocalPage<LocalProduct>> products({
    required String search,
    required StockLevel? level,
    required int offset,
    required int limit,
  }) async {
    final threshold = await lowStockThreshold();
    Expression<bool> filter($LocalProductsTable row) {
      final conditions = <Expression<bool>>[
        if (_needle(search) case final needle?) _containsText(row.searchKey, needle),
        if (level == StockLevel.out) row.quantity.isSmallerOrEqualValue(0),
        if (level == StockLevel.low) row.quantity.isBiggerThanValue(0) & row.quantity.isSmallerOrEqualValue(threshold.toDouble()),
        if (level == StockLevel.ok) row.quantity.isBiggerThanValue(threshold.toDouble()),
      ];
      return Expression.and(conditions);
    }

    final query = _db.select(_db.localProducts)
      ..where(filter)
      ..orderBy([(row) => OrderingTerm.asc(row.searchKey), (row) => OrderingTerm.asc(row.id)])
      ..limit(limit, offset: offset);
    final total = _db.localProducts.id.count();
    final countQuery = _db.selectOnly(_db.localProducts)
      ..addColumns([total])
      ..where(filter(_db.localProducts));

    return (items: await query.get(), total: await countQuery.map((row) => row.read(total) ?? 0).getSingle());
  }

  /// Baixo e esgotado juntos, do menor estoque para o maior (alertas do início), como o filtro "attention" da API.
  Future<List<LocalProduct>> productsNeedingAttention({required int limit}) async {
    final threshold = (await lowStockThreshold()).toDouble();
    final query = _db.select(_db.localProducts)
      ..where((row) => row.quantity.isSmallerOrEqualValue(threshold))
      ..orderBy([(row) => OrderingTerm.asc(row.quantity), (row) => OrderingTerm.asc(row.searchKey)])
      ..limit(limit);
    return query.get();
  }

  Future<LocalProduct?> product(String id) => (_db.select(_db.localProducts)..where((row) => row.id.equals(id))).getSingleOrNull();

  /// Quantos produtos estão em cada situação, para as abas do estoque.
  Future<({int all, int low, int out})> productCounts() async {
    final threshold = (await lowStockThreshold()).toDouble();
    final quantity = _db.localProducts.quantity;
    final all = _db.localProducts.id.count();
    final low = _db.localProducts.id.count(filter: quantity.isBiggerThanValue(0) & quantity.isSmallerOrEqualValue(threshold));
    final out = _db.localProducts.id.count(filter: quantity.isSmallerOrEqualValue(0));
    final row = await (_db.selectOnly(_db.localProducts)..addColumns([all, low, out])).getSingle();
    return (all: row.read(all) ?? 0, low: row.read(low) ?? 0, out: row.read(out) ?? 0);
  }

  /// Reflete na cópia uma venda feita sem internet: o estoque baixa (sem passar de zero, como o servidor
  /// faz com venda offline) e o fiado do cliente sobe. A próxima sincronização traz os valores reais.
  Future<void> applyOfflineSale({required List<({String productId, double quantity})> items, String? customerId, required int totalCents}) {
    return _db.transaction(() async {
      for (final item in items) {
        await _db.customUpdate(
          'UPDATE local_products SET quantity = MAX(quantity - ?, 0) WHERE id = ?',
          variables: [Variable.withReal(item.quantity), Variable.withString(item.productId)],
          updates: {_db.localProducts},
        );
      }
      if (customerId != null) {
        await _db.customUpdate(
          'UPDATE local_customers SET balance_cents = balance_cents + ? WHERE id = ?',
          variables: [Variable.withInt(totalCents), Variable.withString(customerId)],
          updates: {_db.localCustomers},
        );
      }
    });
  }

  /// Reposição feita sem internet: soma na cópia até a próxima sincronização trazer o valor real.
  Future<void> applyRestock({required String productId, required double quantity}) {
    return _db.customUpdate(
      'UPDATE local_products SET quantity = quantity + ? WHERE id = ?',
      variables: [Variable.withReal(quantity), Variable.withString(productId)],
      updates: {_db.localProducts},
    );
  }

  /// Pagamento de fiado recebido sem internet. Quitou: o vencimento some, como o servidor faz.
  Future<void> applyPayment({required String customerId, required int amountCents}) {
    return _db.customUpdate(
      'UPDATE local_customers SET balance_cents = MAX(balance_cents - ?, 0), '
      'credit_due_date = CASE WHEN balance_cents - ? <= 0 THEN NULL ELSE credit_due_date END WHERE id = ?',
      variables: [Variable.withInt(amountCents), Variable.withInt(amountCents), Variable.withString(customerId)],
      updates: {_db.localCustomers},
    );
  }

  // ---------- Clientes ----------

  /// Busca só com dígitos e pontuação de telefone procura no telefone; o resto, no nome (igual ao servidor).
  Future<LocalPage<LocalCustomer>> customers({
    required String search,
    required bool owingOnly,
    required int offset,
    required int limit,
  }) async {
    Expression<bool> filter($LocalCustomersTable row) {
      final conditions = <Expression<bool>>[
        if (_phoneDigits(search) case final digits?)
          _containsText(row.phone, digits)
        else if (_needle(search) case final needle?)
          _containsText(row.searchKey, needle),
        if (owingOnly) row.balanceCents.isBiggerThanValue(0),
      ];
      return Expression.and(conditions);
    }

    final query = _db.select(_db.localCustomers)
      ..where(filter)
      ..orderBy([(row) => OrderingTerm.asc(row.searchKey), (row) => OrderingTerm.asc(row.id)])
      ..limit(limit, offset: offset);
    final total = _db.localCustomers.id.count();
    final countQuery = _db.selectOnly(_db.localCustomers)
      ..addColumns([total])
      ..where(filter(_db.localCustomers));

    return (items: await query.get(), total: await countQuery.map((row) => row.read(total) ?? 0).getSingle());
  }

  Future<LocalCustomer?> customer(String id) => (_db.select(_db.localCustomers)..where((row) => row.id.equals(id))).getSingleOrNull();

  /// Quantos devem e quanto, na última sincronização.
  Future<({int owingCount, int owedCents})> creditTotals() async {
    final balance = _db.localCustomers.balanceCents;
    final owing = _db.localCustomers.id.count(filter: balance.isBiggerThanValue(0));
    final owed = balance.sum(filter: balance.isBiggerThanValue(0));
    final row = await (_db.selectOnly(_db.localCustomers)..addColumns([owing, owed])).getSingle();
    return (owingCount: row.read(owing) ?? 0, owedCents: row.read(owed) ?? 0);
  }

  // ---------- Apoio ----------

  static String searchKeyOf(String name) => name.toLowerCase();

  static String? _needle(String search) {
    final trimmed = search.trim();
    return trimmed.isEmpty ? null : searchKeyOf(trimmed);
  }

  static String? _phoneDigits(String search) {
    final trimmed = search.trim();
    if (!_phoneSearch.hasMatch(trimmed)) return null;
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? null : digits;
  }

  // instr em vez de LIKE: "%" e "_" digitados na busca são texto, não curinga
  static Expression<bool> _containsText(Expression<String> column, String needle) {
    return FunctionCallExpression<int>('instr', [column, Variable<String>(needle)]).isBiggerThanValue(0);
  }

  Future<String?> _mark(String key) async {
    final row = await (_db.select(_db.syncMarks)..where((mark) => mark.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _setMark(String key, String value) {
    return _db.into(_db.syncMarks).insertOnConflictUpdate(SyncMarksCompanion.insert(key: key, value: value));
  }
}
