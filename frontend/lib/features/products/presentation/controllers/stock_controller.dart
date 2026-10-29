import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/network/cancel_signal.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/product.dart';
import '../../domain/products_repository.dart';

enum StockListStatus { loading, ready, failure }

/// Lista do estoque com busca (debounce + cancelamento), filtro e scroll infinito, tudo no servidor.
class StockController extends ChangeNotifier with DisposeAwareNotifier {
  StockController(this._repository, StockChanges changes, {StockFilter initialFilter = StockFilter.all}) : _filter = initialFilter {
    _changesSubscription = changes.stream.listen(_onStockChange);
  }

  final ProductsRepository _repository;
  final Debouncer _searchDebouncer = Debouncer(const Duration(milliseconds: 400));
  late final StreamSubscription<StockChange> _changesSubscription;

  static const pageSize = 30;

  StockListStatus _status = StockListStatus.loading;
  StockFilter _filter;
  String _search = '';
  List<Product> _items = const [];
  int _total = 0;
  StockCounts _counts = StockCounts.empty;
  int _lowStockThreshold = 0;
  bool _isLoadingMore = false;
  AppFailure? _failure;
  AppFailure? _loadMoreFailure;
  CancelSignal? _inFlight;

  /// Muda a cada recarga da primeira página, para descartar atualizações feitas sobre a lista antiga.
  int _listVersion = 0;

  StockListStatus get status => _status;
  StockFilter get filter => _filter;
  List<Product> get items => _items;
  StockCounts get counts => _counts;
  int get lowStockThreshold => _lowStockThreshold;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _items.length < _total;
  AppFailure? get failure => _failure;
  AppFailure? get loadMoreFailure => _loadMoreFailure;

  Future<void> loadFirstPage() async {
    _inFlight?.cancel();
    final signal = _inFlight = CancelSignal();
    _listVersion++;
    _status = StockListStatus.loading;
    _failure = null;
    _loadMoreFailure = null;
    notifyListeners();

    try {
      final page = await _repository.list(search: _search, filter: _filter, offset: 0, limit: pageSize, cancel: signal);
      if (signal.isCancelled) return;
      _apply(page, replace: true);
      _status = StockListStatus.ready;
    } on AppFailure catch (failure) {
      if (signal.isCancelled) return;
      _failure = failure;
      _status = StockListStatus.failure;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _status != StockListStatus.ready) return;
    final signal = _inFlight = CancelSignal();
    _isLoadingMore = true;
    _loadMoreFailure = null;
    notifyListeners();

    try {
      final page = await _repository.list(search: _search, filter: _filter, offset: _items.length, limit: pageSize, cancel: signal);
      if (!signal.isCancelled) _apply(page, replace: false);
    } on AppFailure catch (failure) {
      if (!signal.isCancelled) _loadMoreFailure = failure;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void search(String text) {
    final trimmed = text.trim();
    if (trimmed == _search) return;
    _search = trimmed;
    _searchDebouncer.run(loadFirstPage);
  }

  void selectFilter(StockFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    loadFirstPage();
  }

  void _apply(ProductPage page, {required bool replace}) {
    _items = replace ? page.items : [..._items, ...page.items];
    _total = page.total;
    _counts = page.stockCounts ?? _counts;
    _lowStockThreshold = page.lowStockThreshold;
  }

  void _onStockChange(StockChange change) {
    switch (change) {
      // A posição do novo produto na ordem alfabética só o servidor sabe
      case ProductCreated():
        loadFirstPage();
      case ProductUpdated(:final productId):
        _refreshProduct(productId);
    }
  }

  /// Atualiza só o produto alterado, mantendo as páginas carregadas e a posição da rolagem.
  Future<void> _refreshProduct(String productId) async {
    final index = _items.indexWhere((product) => product.id == productId);
    // Fora do que está carregado o produto pode ter entrado no filtro atual: só o servidor sabe onde
    if (index < 0 || _status != StockListStatus.ready) return loadFirstPage();

    final version = _listVersion;
    final Product updated;
    try {
      updated = await _repository.get(productId);
    } on AppFailure {
      if (!isDisposed && version == _listVersion) await loadFirstPage();
      return;
    }
    // Se a lista foi recarregada no meio-tempo, ela e as contagens já vieram atualizadas do servidor
    if (isDisposed || version != _listVersion) return;

    final current = _items.indexWhere((product) => product.id == productId);
    if (current < 0) return;
    final previous = _items[current];
    _counts = _counts.moved(previous.stockLevel, updated.stockLevel);
    // A busca não é conferida de novo: o produto que o usuário acabou de editar continua visível
    if (_filter.includes(updated.stockLevel)) {
      _items = [..._items]..[current] = updated;
    } else {
      _items = [..._items]..removeAt(current);
      _total -= 1;
      // A página pedida antes da remoção usaria um offset adiantado em um; o rodapé pede de novo
      if (_isLoadingMore) _inFlight?.cancel();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _changesSubscription.cancel();
    _searchDebouncer.dispose();
    _inFlight?.cancel();
    super.dispose();
  }
}
