import 'package:flutter/foundation.dart';

import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';

/// Edição de nome e telefone. A validação definitiva (formato, telefone repetido) é do servidor.
class CustomerEditController extends ChangeNotifier with DisposeAwareNotifier {
  CustomerEditController(this._repository, this.customerId);

  final CustomersRepository _repository;
  final String customerId;

  bool _isSaving = false;
  bool _isDeleting = false;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;

  /// Lança [AppFailure] quando o servidor recusa.
  Future<void> save(CustomerInput input) async {
    if (_isSaving) return;
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.update(customerId, input);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Lança [AppFailure] quando o servidor recusa (ex.: cliente com fiado no histórico).
  Future<void> delete() async {
    if (_isDeleting) return;
    _isDeleting = true;
    notifyListeners();
    try {
      await _repository.delete(customerId);
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
