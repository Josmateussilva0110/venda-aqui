import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../domain/product.dart';
import '../../domain/products_repository.dart';

class RestockController extends ChangeNotifier with DisposeAwareNotifier {
  RestockController(this._repository, this._changes, this.productId);

  final ProductsRepository _repository;
  final StockChanges _changes;
  final String productId;

  Product? _product;
  String _amount = '';
  bool _isLoading = true;
  bool _isSaving = false;
  AppFailure? _loadFailure;
  AppFailure? _saveFailure;

  Product? get product => _product;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  AppFailure? get loadFailure => _loadFailure;
  AppFailure? get saveFailure => _saveFailure;

  double get amount => QuantityFormat.parse(_amount) ?? 0;
  bool get canSave => amount > 0;

  Future<void> load() async {
    _isLoading = true;
    _loadFailure = null;
    notifyListeners();
    try {
      _product = await _repository.get(productId);
    } on AppFailure catch (failure) {
      _loadFailure = failure;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Texto já filtrado pelo campo (inteiro, ou kg com vírgula quando o produto é vendido por peso).
  void setAmount(String text) {
    _saveFailure = null;
    _amount = text;
    notifyListeners();
  }

  /// Verdadeiro quando o servidor confirmou a reposição.
  Future<bool> save() async {
    if (!canSave || _isSaving) return false;
    _isSaving = true;
    _saveFailure = null;
    notifyListeners();
    try {
      await _repository.restock(productId, amount);
      _changes.notify(ProductUpdated(productId));
      return true;
    } on AppFailure catch (failure) {
      _saveFailure = failure;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
