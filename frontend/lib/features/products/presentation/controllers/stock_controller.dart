import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/network/cancel_signal.dart';
import '../../../../core/utils/debouncer.dart';
import '../../domain/product.dart';
import '../../domain/products_repository.dart';

enum StockListStatus { loading, ready, failure }

/// Lista do estoque com busca (debounce + cancelamento), filtro e scroll infinito, tudo no servidor.
class StockController extends ChangeNotifier {
  StockController(this._repository, {StockFilter initialFilter = StockFilter.all}) : _filter = initialFilter;

  final ProductsRepository _repository;
  final Debouncer _searchDebouncer = Debouncer(const Duration(milliseconds: 400));

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
    _counts = page.stockCounts;
    _lowStockThreshold = page.lowStockThreshold;
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _inFlight?.cancel();
    super.dispose();
  }
}
