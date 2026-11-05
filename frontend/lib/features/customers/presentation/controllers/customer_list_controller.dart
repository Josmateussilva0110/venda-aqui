import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/network/cancel_signal.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';

enum CustomerListStatus { loading, ready, failure }

/// Lista paginada de clientes com busca e filtro de saldo, tudo no servidor.
/// Serve à tela de devedores e à escolha do cliente na venda fiado.
class CustomerListController extends ChangeNotifier with DisposeAwareNotifier {
  CustomerListController(this._repository, {CustomerBalanceFilter initialFilter = CustomerBalanceFilter.all}) : _filter = initialFilter;

  final CustomersRepository _repository;
  final Debouncer _searchDebouncer = Debouncer(const Duration(milliseconds: 400));

  static const pageSize = 30;

  CustomerListStatus _status = CustomerListStatus.loading;
  CustomerBalanceFilter _filter;
  String _search = '';
  List<Customer> _items = const [];
  int _total = 0;
  CreditSummary? _summary;
  bool _isLoadingMore = false;
  AppFailure? _failure;
  AppFailure? _loadMoreFailure;
  CancelSignal? _inFlight;

  CustomerListStatus get status => _status;
  CustomerBalanceFilter get filter => _filter;
  String get search => _search;
  List<Customer> get items => _items;
  CreditSummary? get summary => _summary;
  bool get hasMore => _items.length < _total;
  bool get isLoadingMore => _isLoadingMore;
  AppFailure? get failure => _failure;
  AppFailure? get loadMoreFailure => _loadMoreFailure;

  /// [silent] mantém a lista na tela enquanto busca (ex.: ao voltar de um pagamento).
  Future<void> loadFirstPage({bool silent = false}) async {
    _inFlight?.cancel();
    final signal = _inFlight = CancelSignal();
    if (!silent || _status != CustomerListStatus.ready) {
      _status = CustomerListStatus.loading;
      _failure = null;
    }
    _loadMoreFailure = null;
    notifyListeners();

    try {
      final page = await _repository.list(search: _search, balance: _filter, offset: 0, limit: pageSize, cancel: signal);
      if (signal.isCancelled) return;
      _items = page.items;
      _total = page.total;
      _summary = page.summary;
      _status = CustomerListStatus.ready;
    } on AppFailure catch (failure) {
      if (signal.isCancelled) return;
      _failure = failure;
      _status = CustomerListStatus.failure;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _status != CustomerListStatus.ready || _loadMoreFailure != null) return;
    final signal = _inFlight = CancelSignal();
    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _repository.list(search: _search, balance: _filter, offset: _items.length, limit: pageSize, cancel: signal);
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

  Future<void> retryLoadMore() {
    _loadMoreFailure = null;
    return loadMore();
  }

  void selectFilter(CustomerBalanceFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    loadFirstPage();
  }

  void setSearch(String text) {
    final trimmed = text.trim();
    if (trimmed == _search) return;
    _search = trimmed;
    _searchDebouncer.run(loadFirstPage);
  }

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  /// Cadastra e põe o cliente no topo da lista, sem esperar outra busca.
  /// Lança [AppFailure] quando o servidor recusa (telefone repetido, campo inválido).
  Future<Customer> create(CustomerInput input) async {
    _isCreating = true;
    notifyListeners();
    try {
      final customer = await _repository.create(input);
      _items = [customer, ..._items.where((item) => item.id != customer.id)];
      _total += 1;
      return customer;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _inFlight?.cancel();
    super.dispose();
  }
}
