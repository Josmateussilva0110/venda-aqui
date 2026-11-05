import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/sale.dart';
import '../../domain/sales_repository.dart';

/// [missingCustomer]: fiado sem cliente. [deletedProduct]: um item aponta para produto já excluído,
/// que o servidor não aceita de volta; o comerciante precisa tirar o item para salvar.
enum SaleEditIssue { noItems, missingCustomer, deletedProduct }

/// Edição de uma venda já registrada: quantidades, itens removidos e forma de pagamento.
class SaleEditController extends ChangeNotifier with DisposeAwareNotifier {
  SaleEditController(this._repository, this._stockChanges, this._original)
    : _items = List.of(_original.items),
      _method = _original.method,
      _customer = _original.customer;

  final SalesRepository _repository;
  final StockChanges _stockChanges;
  final Sale _original;

  List<SaleItem> _items;
  PaymentMethod _method;
  SaleCustomer? _customer;
  bool _isSaving = false;
  SaleEditIssue? _issue;
  AppFailure? _failure;

  List<SaleItem> get items => List.unmodifiable(_items);
  PaymentMethod get method => _method;

  /// Cliente do fiado; só vale quando [method] é fiado.
  SaleCustomer? get customer => _customer;
  bool get isSaving => _isSaving;
  SaleEditIssue? get issue => _issue;
  AppFailure? get failure => _failure;

  /// Só para exibição; o total que vale é o do servidor.
  int get totalCents => _items.fold(0, (sum, item) => sum + item.subtotalCents);

  void setQuantity(int index, double quantity) {
    // Zero fica na lista até salvar (o item some ao salvar); negativo não existe
    final rounded = quantity <= 0 ? 0.0 : (quantity * 1000).round() / 1000;
    _items = [..._items]..[index] = _items[index].copyWith(quantity: rounded);
    _issue = null;
    notifyListeners();
  }

  void remove(int index) {
    _items = [..._items]..removeAt(index);
    _issue = null;
    notifyListeners();
  }

  void selectMethod(PaymentMethod method) {
    _method = method;
    _issue = null;
    notifyListeners();
  }

  void selectCustomer(SaleCustomer customer) {
    _customer = customer;
    _issue = null;
    notifyListeners();
  }

  /// A venda salva, ou nula quando não deu (veja [issue] e [failure]).
  Future<Sale?> save() async {
    if (_isSaving) return null;
    final items = _items.where((item) => item.quantity > 0).toList(growable: false);
    final issue = _issueFor(items);
    if (issue != null) {
      _issue = issue;
      notifyListeners();
      return null;
    }
    _isSaving = true;
    _failure = null;
    notifyListeners();
    try {
      final input = SaleInput(items: items, method: _method, customer: _method == PaymentMethod.credit ? _customer : null);
      final saved = await _repository.update(_original.id, input, createdAt: _original.createdAt);
      _stockChanges.notify(const StockSold());
      return saved;
    } on AppFailure catch (failure) {
      _failure = failure;
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Conferência só para avisar cedo; o servidor revalida tudo
  SaleEditIssue? _issueFor(List<SaleItem> items) {
    if (items.isEmpty) return SaleEditIssue.noItems;
    if (items.any((item) => item.productId == null)) return SaleEditIssue.deletedProduct;
    if (_method == PaymentMethod.credit && _customer == null) return SaleEditIssue.missingCustomer;
    return null;
  }
}
