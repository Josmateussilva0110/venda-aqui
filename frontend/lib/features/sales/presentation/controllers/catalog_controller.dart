import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/network/cancel_signal.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/sale.dart';
import '../../domain/sales_repository.dart';

enum CatalogStatus { loading, ready, failure }

/// Grade de produtos da venda: busca (debounce + cancelamento) e scroll infinito, tudo no servidor.
class CatalogController extends ChangeNotifier with DisposeAwareNotifier {
  CatalogController(this._repository);

  final SalesRepository _repository;
  final Debouncer _searchDebouncer = Debouncer(const Duration(milliseconds: 400));

  static const pageSize = 30;

  CatalogStatus _status = CatalogStatus.loading;
  String _search = '';
  List<CatalogProduct> _items = const [];
  int _total = 0;
  bool _isLoadingMore = false;
  AppFailure? _failure;
  AppFailure? _loadMoreFailure;
  CancelSignal? _inFlight;

  CatalogStatus get status => _status;
  List<CatalogProduct> get items => _items;
  bool get hasMore => _items.length < _total;
  bool get isLoadingMore => _isLoadingMore;
  AppFailure? get failure => _failure;
  AppFailure? get loadMoreFailure => _loadMoreFailure;

  Future<void> loadFirstPage() async {
    _inFlight?.cancel();
    final signal = _inFlight = CancelSignal();
    _status = CatalogStatus.loading;
    _failure = null;
    _loadMoreFailure = null;
    notifyListeners();

    try {
      final page = await _repository.catalog(search: _search, offset: 0, limit: pageSize, cancel: signal);
      if (signal.isCancelled) return;
      _items = page.items;
      _total = page.total;
      _status = CatalogStatus.ready;
    } on AppFailure catch (failure) {
      if (signal.isCancelled) return;
      _failure = failure;
      _status = CatalogStatus.failure;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _status != CatalogStatus.ready || _loadMoreFailure != null) return;
    final signal = _inFlight = CancelSignal();
    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _repository.catalog(search: _search, offset: _items.length, limit: pageSize, cancel: signal);
      if (!signal.isCancelled) {
        _items = [..._items, ...page.items];
        _total = page.total;
      }
    } on AppFailure catch (failure) {
      if (!signal.isCancelled) _loadMoreFailure = failure;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Nova tentativa pelo botão do rodapé, depois de uma falha ao carregar mais.
  Future<void> retryLoadMore() {
    _loadMoreFailure = null;
    return loadMore();
  }

  void search(String text) {
    final trimmed = text.trim();
    if (trimmed == _search) return;
    _search = trimmed;
    _searchDebouncer.run(loadFirstPage);
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _inFlight?.cancel();
    super.dispose();
  }
}
