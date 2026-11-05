import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/network/cancel_signal.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/sale.dart';
import '../../domain/sales_repository.dart';

enum HistoryPeriod { today, week, month, custom }

enum HistoryStatus { loading, ready, failure, invalidRange }

/// Vendas de um dia, como aparecem agrupadas no histórico.
@immutable
class SaleDayGroup {
  const SaleDayGroup({required this.day, required this.sales});

  final DateTime day;
  final List<Sale> sales;

  int get totalCents => sales.fold(0, (sum, sale) => sum + sale.totalCents);
}

/// Histórico com período, forma de pagamento e busca; o filtro é feito por quem implementa o repositório.
class SalesHistoryController extends ChangeNotifier with DisposeAwareNotifier {
  SalesHistoryController(this._repository, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    final today = _today();
    _customFrom = today.subtract(const Duration(days: _weekDays - 1));
    _customTo = today;
  }

  final SalesRepository _repository;
  final DateTime Function() _clock;
  final Debouncer _searchDebouncer = Debouncer(const Duration(milliseconds: 400));

  static const pageSize = 50;
  static const _weekDays = 7;
  static const _monthDays = 30;

  HistoryStatus _status = HistoryStatus.loading;
  HistoryPeriod _period = HistoryPeriod.today;
  late DateTime _customFrom;
  late DateTime _customTo;
  PaymentMethod? _method;
  String _search = '';
  List<Sale> _sales = const [];
  List<SaleDayGroup> _groups = const [];
  int _total = 0;
  int _totalCents = 0;
  bool _isLoadingMore = false;
  AppFailure? _failure;
  AppFailure? _loadMoreFailure;
  CancelSignal? _inFlight;

  HistoryStatus get status => _status;
  HistoryPeriod get period => _period;
  DateTime get customFrom => _customFrom;
  DateTime get customTo => _customTo;
  DateTime get today => _today();
  PaymentMethod? get method => _method;
  List<SaleDayGroup> get groups => _groups;
  AppFailure? get failure => _failure;
  AppFailure? get loadMoreFailure => _loadMoreFailure;
  bool get hasMore => _sales.length < _total;
  bool get isLoadingMore => _isLoadingMore;

  /// Resumo do filtro inteiro, vindo do servidor (a lista pode ter só a primeira página).
  int get saleCount => _total;
  int get totalCents => _totalCents;

  /// [silent] mantém a lista na tela enquanto busca (ex.: ao voltar de uma edição), sem perder a rolagem.
  Future<void> load({bool silent = false}) async {
    _inFlight?.cancel();
    final (from, to) = _range();
    if (from.isAfter(to)) {
      _status = HistoryStatus.invalidRange;
      _applyPage(const SaleHistoryPage(items: [], total: 0, totalCents: 0));
      notifyListeners();
      return;
    }
    final signal = _inFlight = CancelSignal();
    if (!silent || _status != HistoryStatus.ready) {
      _status = HistoryStatus.loading;
      _failure = null;
      notifyListeners();
    }
    _loadMoreFailure = null;

    try {
      final page = await _repository.history(_filter(from, to), offset: 0, limit: pageSize, cancel: signal);
      if (signal.isCancelled) return;
      _applyPage(page);
      _status = HistoryStatus.ready;
    } on AppFailure catch (failure) {
      if (signal.isCancelled) return;
      _failure = failure;
      _status = HistoryStatus.failure;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _status != HistoryStatus.ready || _loadMoreFailure != null) return;
    final (from, to) = _range();
    final signal = _inFlight = CancelSignal();
    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _repository.history(_filter(from, to), offset: _sales.length, limit: pageSize, cancel: signal);
      if (!signal.isCancelled) {
        _applyPage(SaleHistoryPage(items: [..._sales, ...page.items], total: page.total, totalCents: page.totalCents));
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

  void selectPeriod(HistoryPeriod period) {
    if (period == _period) return;
    _period = period;
    load();
  }

  void setCustomRange({DateTime? from, DateTime? to}) {
    _customFrom = from ?? _customFrom;
    _customTo = to ?? _customTo;
    load();
  }

  void selectMethod(PaymentMethod? method) {
    if (method == _method) return;
    _method = method;
    load();
  }

  void search(String text) {
    final trimmed = text.trim();
    if (trimmed == _search) return;
    _search = trimmed;
    _searchDebouncer.run(load);
  }

  SaleFilter _filter(DateTime from, DateTime to) => SaleFilter(from: from, to: to, method: _method, search: _search);

  void _applyPage(SaleHistoryPage page) {
    _sales = page.items;
    _total = page.total;
    _totalCents = page.totalCents;
    _groups = _groupByDay(page.items);
  }

  (DateTime, DateTime) _range() {
    final today = _today();
    return switch (_period) {
      HistoryPeriod.today => (today, today),
      HistoryPeriod.week => (today.subtract(const Duration(days: _weekDays - 1)), today),
      HistoryPeriod.month => (today.subtract(const Duration(days: _monthDays - 1)), today),
      HistoryPeriod.custom => (_customFrom, _customTo),
    };
  }

  DateTime _today() {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  // As vendas já chegam da mais recente para a mais antiga
  List<SaleDayGroup> _groupByDay(List<Sale> sales) {
    final groups = <SaleDayGroup>[];
    for (final sale in sales) {
      final day = DateTime(sale.createdAt.year, sale.createdAt.month, sale.createdAt.day);
      if (groups.isEmpty || groups.last.day != day) {
        groups.add(SaleDayGroup(day: day, sales: [sale]));
      } else {
        groups.last.sales.add(sale);
      }
    }
    return groups;
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _inFlight?.cancel();
    super.dispose();
  }
}
