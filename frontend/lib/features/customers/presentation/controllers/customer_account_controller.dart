import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';

/// Por que o pagamento não foi enviado. A conferência aqui é só para avisar cedo:
/// o teto real (não pagar mais do que deve) é conferido pelo servidor.
enum PaymentIssue { invalidAmount, exceedsBalance }

/// Conta do cliente: saldo, extrato paginado e recebimento do fiado.
class CustomerAccountController extends ChangeNotifier with DisposeAwareNotifier {
  CustomerAccountController(this._repository, this.customerId);

  final CustomersRepository _repository;
  final String customerId;

  static const pageSize = 30;

  Customer? _customer;
  List<StatementEntry> _entries = const [];
  int _total = 0;
  AppFailure? _failure;
  bool _isLoadingMore = false;
  AppFailure? _loadMoreFailure;
  bool _isPaying = false;
  bool _changed = false;
  int _version = 0;

  Customer? get customer => _customer;
  List<StatementEntry> get entries => _entries;
  bool get hasMore => _entries.length < _total;
  bool get isLoadingMore => _isLoadingMore;
  AppFailure? get failure => _failure;
  AppFailure? get loadMoreFailure => _loadMoreFailure;
  bool get isPaying => _isPaying;

  /// Avisa quem abriu a conta (a lista de devedores) se precisa buscar de novo.
  bool get changed => _changed;

  Future<void> load() async {
    final version = ++_version;
    _failure = null;
    _loadMoreFailure = null;
    notifyListeners();
    try {
      // Independentes: em paralelo
      final (customer, page) = await (_repository.get(customerId), _repository.statement(customerId, offset: 0, limit: pageSize)).wait;
      if (version != _version) return;
      _customer = customer;
      _entries = page.items;
      _total = page.total;
    } on ParallelWaitError<(Customer?, StatementPage?), (AsyncError?, AsyncError?)> catch (error) {
      if (version != _version) return;
      _failure = _firstFailure(error.errors);
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _loadMoreFailure != null) return;
    final version = _version;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final page = await _repository.statement(customerId, offset: _entries.length, limit: pageSize);
      if (version == _version) {
        _entries = [..._entries, ...page.items];
        _total = page.total;
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
    // Sem nada carregado (falhou a recarga depois do pagamento), tenta a primeira página de novo
    return _entries.isEmpty ? _reloadStatement() : loadMore();
  }

  PaymentIssue? validatePayment(int? amountCents) {
    final balance = _customer?.balanceCents ?? 0;
    if (amountCents == null || amountCents <= 0) return PaymentIssue.invalidAmount;
    if (amountCents > balance) return PaymentIssue.exceedsBalance;
    return null;
  }

  /// Registra o pagamento e recarrega o extrato. Lança [AppFailure] quando o servidor recusa.
  Future<void> registerPayment({required int amountCents, required SettlementMethod method}) async {
    final customer = _customer;
    if (_isPaying || customer == null) return;
    _isPaying = true;
    notifyListeners();
    try {
      final balance = await _repository.registerPayment(customerId, amountCents: amountCents, method: method);
      _customer = customer.copyWith(balanceCents: balance);
      _changed = true;
    } finally {
      _isPaying = false;
      notifyListeners();
    }
    // O saldo já veio na resposta; só o extrato precisa vir de novo, com o pagamento no topo
    await _reloadStatement();
  }

  Future<void> _reloadStatement() async {
    final version = ++_version;
    _loadMoreFailure = null;
    try {
      final page = await _repository.statement(customerId, offset: 0, limit: pageSize);
      if (version != _version) return;
      _entries = page.items;
      _total = page.total;
    } on AppFailure catch (failure) {
      // O pagamento já foi registrado: a falha fica só no rodapé do extrato, com nova tentativa
      if (version == _version) _loadMoreFailure = failure;
    }
    notifyListeners();
  }

  AppFailure _firstFailure((AsyncError?, AsyncError?) errors) {
    for (final error in [errors.$1, errors.$2]) {
      final cause = error?.error;
      if (cause is AppFailure) return cause;
    }
    return const ServerFailure();
  }
}
