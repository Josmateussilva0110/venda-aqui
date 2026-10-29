import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/product.dart';
import '../../domain/products_repository.dart';

enum SaveOutcome { saved, savedWithoutPhoto, failed }

/// Salva produto (cadastro ou edição) e envia a foto; as páginas decidem qual operação chamar.
class ProductEditorController extends ChangeNotifier with DisposeAwareNotifier {
  ProductEditorController(this._repository, this._changes);

  final ProductsRepository _repository;
  final StockChanges _changes;

  Product? _product;
  bool _isLoading = false;
  bool _isSaving = false;
  AppFailure? _loadFailure;
  AppFailure? _saveFailure;

  Product? get product => _product;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  AppFailure? get loadFailure => _loadFailure;
  AppFailure? get saveFailure => _saveFailure;

  Future<void> load(String id) async {
    _isLoading = true;
    _loadFailure = null;
    notifyListeners();
    try {
      _product = await _repository.get(id);
    } on AppFailure catch (failure) {
      _loadFailure = failure;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SaveOutcome> create(ProductInput input, ProductPhoto? photo) {
    return _save(() => _repository.create(input), photo, ProductCreated.new);
  }

  Future<SaveOutcome> update(String id, ProductInput input, ProductPhoto? photo) {
    return _save(
      () async {
        await _repository.update(id, input);
        return id;
      },
      photo,
      ProductUpdated.new,
    );
  }

  Future<SaveOutcome> _save(Future<String> Function() persist, ProductPhoto? photo, StockChange Function(String id) change) async {
    if (_isSaving) return SaveOutcome.failed;
    _isSaving = true;
    _saveFailure = null;
    notifyListeners();
    try {
      final id = await persist();
      // Um aviso só, depois da foto, para as listas não buscarem o produto ainda sem ela
      final outcome = await _uploadPhoto(id, photo);
      _changes.notify(change(id));
      return outcome;
    } on AppFailure catch (failure) {
      _saveFailure = failure;
      return SaveOutcome.failed;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // A foto depende do id: se falhar, o produto já está salvo e o usuário pode tentar de novo
  Future<SaveOutcome> _uploadPhoto(String id, ProductPhoto? photo) async {
    if (photo == null) return SaveOutcome.saved;
    try {
      await _repository.uploadPhoto(id, photo);
      return SaveOutcome.saved;
    } on AppFailure {
      return SaveOutcome.savedWithoutPhoto;
    }
  }
}
