import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/statement_entry.dart';
import '../../domain/stores_repository.dart';

/// Extrato de uma loja, paginado pelo servidor e carregado conforme a rolagem.
class StatementController extends ChangeNotifier with DisposeAwareNotifier {
  StatementController(this._repository, {required this.storeId});

  final StoresRepository _repository;
  final String storeId;

  static const pageSize = 30;

  List<StatementEntry> _items = const [];
  bool _hasMore = true;
  bool _isLoadingFirst = true;
  bool _isLoadingMore = false;
  AppFailure? _firstPageFailure;
  AppFailure? _nextPageFailure;

  List<StatementEntry> get items => _items;
  bool get hasMore => _hasMore;
  bool get isLoadingFirst => _isLoadingFirst;
  bool get isLoadingMore => _isLoadingMore;
  AppFailure? get firstPageFailure => _firstPageFailure;
  AppFailure? get nextPageFailure => _nextPageFailure;

  Future<void> loadFirst() async {
    _isLoadingFirst = true;
    _firstPageFailure = null;
    notifyListeners();
    try {
      final page = await _repository.statement(storeId, offset: 0, limit: pageSize);
      _items = page.items;
      _hasMore = page.hasMore;
      _nextPageFailure = null;
    } on AppFailure catch (failure) {
      _firstPageFailure = failure;
    } finally {
      _isLoadingFirst = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingFirst || _isLoadingMore || !_hasMore || _nextPageFailure != null) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final page = await _repository.statement(storeId, offset: _items.length, limit: pageSize);
      // Paginação por posição: um lançamento novo na loja empurra a lista e repete o último item da página anterior
      final known = {for (final entry in _items) entry.id};
      _items = [..._items, ...page.items.where((entry) => !known.contains(entry.id))];
      _hasMore = page.hasMore && page.items.isNotEmpty;
    } on AppFailure catch (failure) {
      _nextPageFailure = failure;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Nova tentativa depois de falhar uma página do meio.
  Future<void> retryMore() {
    _nextPageFailure = null;
    return loadMore();
  }
}
