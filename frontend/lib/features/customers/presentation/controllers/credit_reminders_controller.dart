import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';

enum RemindersStatus { loading, ready, failure }

/// Lembretes pendentes, paginados pelo servidor. Quem já recebeu o lembrete continua na tela
/// (marcado como enviado) até a próxima recarga, para o comerciante poder enviar de novo.
class CreditRemindersController extends ChangeNotifier with DisposeAwareNotifier {
  CreditRemindersController(this._repository);

  final CustomersRepository _repository;

  static const pageSize = 30;

  RemindersStatus _status = RemindersStatus.loading;
  List<CreditReminder> _items = const [];
  final Set<String> _sentIds = {};

  // Pendentes no servidor; cai a cada envio, porque o enviado sai da consulta
  int _pendingTotal = 0;
  AppFailure? _failure;
  bool _isLoadingMore = false;
  AppFailure? _loadMoreFailure;
  bool _changed = false;
  int _version = 0;

  RemindersStatus get status => _status;
  List<CreditReminder> get items => _items;
  AppFailure? get failure => _failure;
  bool get isLoadingMore => _isLoadingMore;
  AppFailure? get loadMoreFailure => _loadMoreFailure;
  bool isSent(String customerId) => _sentIds.contains(customerId);

  /// Avisa quem abriu a tela que o resumo do fiado (e o aviso agendado) precisa ser conferido.
  bool get changed => _changed;

  int get _unsentLoaded => _items.length - _sentIds.length;
  bool get hasMore => _unsentLoaded < _pendingTotal;

  Future<void> loadFirstPage() async {
    final version = ++_version;
    if (_status != RemindersStatus.ready) _status = RemindersStatus.loading;
    _failure = null;
    _loadMoreFailure = null;
    notifyListeners();
    try {
      final page = await _repository.reminders(offset: 0, limit: pageSize);
      if (version != _version) return;
      _items = page.items;
      _pendingTotal = page.total;
      _sentIds.clear();
      _status = RemindersStatus.ready;
    } on AppFailure catch (failure) {
      if (version != _version) return;
      _failure = failure;
      _status = RemindersStatus.failure;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _loadMoreFailure != null) return;
    final version = _version;
    _isLoadingMore = true;
    notifyListeners();
    try {
      // Os enviados já não contam no servidor: a próxima página começa depois dos não enviados
      final page = await _repository.reminders(offset: _unsentLoaded, limit: pageSize);
      if (version == _version) {
        _items = [..._items, ...page.items];
        _pendingTotal = page.total;
      }
    } on AppFailure catch (failure) {
      if (version == _version) _loadMoreFailure = failure;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> retryLoadMore() {
    _loadMoreFailure = null;
    return loadMore();
  }

  /// Registra o envio depois que o WhatsApp abriu. Lança [AppFailure] se o servidor recusar.
  Future<void> markSent(String customerId) async {
    if (_sentIds.contains(customerId)) return;
    await _repository.markReminded(customerId);
    _sentIds.add(customerId);
    _pendingTotal = _pendingTotal > 0 ? _pendingTotal - 1 : 0;
    _changed = true;
    notifyListeners();
  }
}
