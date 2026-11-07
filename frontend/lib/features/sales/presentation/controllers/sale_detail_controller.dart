import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/sale.dart';
import '../../domain/sales_repository.dart';

class SaleDetailController extends ChangeNotifier with DisposeAwareNotifier {
  SaleDetailController(this._repository, this.saleId);

  final SalesRepository _repository;
  final String saleId;

  Sale? _sale;
  AppFailure? _failure;
  bool _wasEdited = false;

  Sale? get sale => _sale;
  AppFailure? get failure => _failure;

  /// Avisa quem abriu o detalhe (o histórico) se precisa buscar de novo.
  bool get wasEdited => _wasEdited;

  Future<void> load() async {
    _failure = null;
    notifyListeners();
    try {
      _sale = await _repository.get(saleId);
    } on AppFailure catch (failure) {
      _failure = failure;
    }
    notifyListeners();
  }

  /// A edição devolve a venda já salva: atualiza sem buscar de novo.
  void replace(Sale sale) {
    _sale = sale;
    _wasEdited = true;
    notifyListeners();
  }
}
