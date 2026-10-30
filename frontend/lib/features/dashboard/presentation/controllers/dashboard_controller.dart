import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/stock_overview.dart';

class DashboardController extends ChangeNotifier with DisposeAwareNotifier {
  DashboardController(this._repository, StockChanges changes) {
    // Qualquer mudança pode mexer nos totais e nos alertas; o resumo é uma requisição só
    _changesSubscription = changes.stream.listen((_) => load());
  }

  final DashboardRepository _repository;
  late final StreamSubscription<StockChange> _changesSubscription;

  static const alertLimit = 3;

  StockOverview? _overview;
  AppFailure? _failure;
  bool _isLoading = false;
  int _lastRequest = 0;

  StockOverview? get overview => _overview;
  AppFailure? get failure => _failure;
  bool get isLoading => _isLoading;

  Future<void> load() async {
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

  @override
  void dispose() {
    _changesSubscription.cancel();
    super.dispose();
  }
}
