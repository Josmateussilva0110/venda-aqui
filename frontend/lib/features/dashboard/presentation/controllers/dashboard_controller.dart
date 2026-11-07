import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/stock_overview.dart';

class DashboardController extends ChangeNotifier with DisposeAwareNotifier {
  DashboardController(this._repository, StockChanges changes, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    // Qualquer mudança pode mexer nos alertas; só a venda mexe também no faturamento e no fiado
    _changesSubscription = changes.stream.listen((change) => change is StockSold ? load() : loadStock());
  }

  final DashboardRepository _repository;
  final DateTime Function() _clock;
  late final StreamSubscription<StockChange> _changesSubscription;

  static const alertLimit = 3;

  /// Vendas de hoje mostradas no início; o resto fica no histórico.
  static const recentSalesLimit = 5;

  StockOverview? _overview;
  CreditOverview? _credit;
  AppFailure? _failure;
  bool _isLoading = false;
  int _lastRequest = 0;
  int _lastCreditRequest = 0;
  int _lastSalesRequest = 0;
  TodaySales? _todaySales;
  AppFailure? _salesFailure;

  StockOverview? get overview => _overview;

  /// Nulo enquanto carrega ou se falhou: o cartão do fiado some sem atrapalhar o resto do início.
  CreditOverview? get credit => _credit;
  AppFailure? get failure => _failure;
  TodaySales? get todaySales => _todaySales;
  AppFailure? get salesFailure => _salesFailure;
  bool get isLoading => _isLoading;

  /// Tudo em paralelo (abertura, puxar para atualizar e depois de uma venda).
  Future<void> load() => Future.wait([loadSales(), loadStock(), loadCredit()]);

  Future<void> loadSales() async {
    final request = ++_lastSalesRequest;
    _salesFailure = null;
    notifyListeners();
    try {
      final sales = await _repository.todaySales(_clock(), recentLimit: recentSalesLimit);
      if (request != _lastSalesRequest) return;
      _todaySales = sales;
    } on AppFailure catch (failure) {
      if (request != _lastSalesRequest) return;
      _salesFailure = failure;
    }
    notifyListeners();
  }

  Future<void> loadStock() async {
    // Um aviso de mudança e o puxar para atualizar podem se sobrepor: vale só a resposta mais recente
    final request = ++_lastRequest;
    _isLoading = true;
    _failure = null;
    notifyListeners();
    try {
      final overview = await _repository.stockOverview(alertLimit: alertLimit);
      if (request != _lastRequest) return;
      _overview = overview;
    } on AppFailure catch (failure) {
      if (request != _lastRequest) return;
      _failure = failure;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// A falha do fiado não aparece como erro: o cartão só some, sem atrapalhar o resto do início.
  Future<void> loadCredit() async {
    final request = ++_lastCreditRequest;
    try {
      final credit = await _repository.creditOverview();
      if (request != _lastCreditRequest) return;
      _credit = credit;
    } on AppFailure {
      if (request != _lastCreditRequest) return;
      _credit = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _changesSubscription.cancel();
    super.dispose();
  }
}
