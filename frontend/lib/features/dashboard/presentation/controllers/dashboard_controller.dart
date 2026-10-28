import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../domain/stock_overview.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._repository);

  final DashboardRepository _repository;

  static const alertLimit = 3;

  StockOverview? _overview;
  AppFailure? _failure;
  bool _isLoading = false;

  StockOverview? get overview => _overview;
  AppFailure? get failure => _failure;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();
    try {
      _overview = await _repository.stockOverview(alertLimit: alertLimit);
    } on AppFailure catch (failure) {
      _failure = failure;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
