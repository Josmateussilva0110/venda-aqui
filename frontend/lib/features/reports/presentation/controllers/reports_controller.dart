import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/sales_report.dart';

enum ReportPeriod { today, week, month, custom }

/// Relatório do período escolhido. Os números vêm prontos do servidor.
class ReportsController extends ChangeNotifier with DisposeAwareNotifier {
  ReportsController(this._repository, StockChanges changes, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    final today = _today();
    _customFrom = today.subtract(const Duration(days: _weekDays - 1));
    _customTo = today;
    // A aba fica viva escondida: a venda só marca o relatório como velho, e ele é recalculado quando a aba
    // volta a aparecer ([refreshIfStale]), em vez de uma consulta no servidor a cada venda
    _changesSubscription = changes.stream.where((change) => change is StockSold).listen((_) => _isStale = true);
  }

  final ReportsRepository _repository;
  final DateTime Function() _clock;
  late final StreamSubscription<StockChange> _changesSubscription;

  static const _weekDays = 7;
  static const _monthDays = 30;

  ReportPeriod _period = ReportPeriod.today;
  late DateTime _customFrom;
  late DateTime _customTo;
  SalesReport? _report;
  AppFailure? _failure;
  int _lastRequest = 0;
  bool _isStale = false;

  ReportPeriod get period => _period;
  DateTime get customFrom => _customFrom;
  DateTime get customTo => _customTo;
  DateTime get today => _today();
  SalesReport? get report => _report;
  AppFailure? get failure => _failure;

  /// Datas invertidas no período personalizado: o relatório usa a ordem certa e a tela avisa.
  bool get isRangeSwapped => _period == ReportPeriod.custom && _customFrom.isAfter(_customTo);

  /// Período efetivo (já na ordem certa), para o subtítulo da tela.
  (DateTime, DateTime) get range {
    final today = _today();
    return switch (_period) {
      ReportPeriod.today => (today, today),
      ReportPeriod.week => (today.subtract(const Duration(days: _weekDays - 1)), today),
      ReportPeriod.month => (today.subtract(const Duration(days: _monthDays - 1)), today),
      ReportPeriod.custom => isRangeSwapped ? (_customTo, _customFrom) : (_customFrom, _customTo),
    };
  }

  Future<void> refreshIfStale() async {
    if (_isStale) await load();
  }

  Future<void> load() async {
    _isStale = false;
    final request = ++_lastRequest;
    _failure = null;
    notifyListeners();
    final (from, to) = range;
    try {
      final report = await _repository.salesReport(from: from, to: to);
      if (request != _lastRequest) return;
      _report = report;
    } on AppFailure catch (failure) {
      if (request != _lastRequest) return;
      _failure = failure;
    }
    notifyListeners();
  }

  void selectPeriod(ReportPeriod period) {
    if (period == _period) return;
    _period = period;
    _report = null;
    load();
  }

  void setCustomRange({DateTime? from, DateTime? to}) {
    _customFrom = from ?? _customFrom;
    _customTo = to ?? _customTo;
    _report = null;
    load();
  }

  DateTime _today() {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _changesSubscription.cancel();
    super.dispose();
  }
}
