import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../domain/sale.dart';
import '../../domain/sales_repository.dart';

/// Por que um item não entrou no carrinho. A conferência de estoque aqui é só para avisar cedo;
/// quem garante o estoque é o servidor ao registrar a venda.
enum CartIssue { outOfStock, insufficientStock, invalidQuantity }

@immutable
class CartLine {
  const CartLine({required this.product, required this.quantity});

  final CatalogProduct product;
  final double quantity;

  /// Só para exibição; o total que vale é o do servidor.
  int get subtotalCents => (product.salePriceCents * quantity).round();
}

/// Carrinho da venda em andamento. Vive enquanto a sessão existir para sobreviver à navegação
/// entre vender, peso, resumo e pagamento.
class SaleCartController extends ChangeNotifier {
  SaleCartController(this._repository, this._stockChanges);

  final SalesRepository _repository;
  final StockChanges _stockChanges;

  // Mantém a ordem em que os produtos entraram, como no resumo
  final Map<String, CartLine> _lines = {};
  bool _isCheckingOut = false;
  AppFailure? _checkoutFailure;

  List<CartLine> get lines => List.unmodifiable(_lines.values);
  bool get isEmpty => _lines.isEmpty;
  bool get isCheckingOut => _isCheckingOut;
  AppFailure? get checkoutFailure => _checkoutFailure;

  int get totalCents => _lines.values.fold(0, (sum, line) => sum + line.subtotalCents);

  /// Produtos por peso contam como um item cada.
  int get itemCount => _lines.values.fold(0, (sum, line) => sum + (line.product.soldByWeight ? 1 : line.quantity.round()));

  double quantityOf(String productId) => _lines[productId]?.quantity ?? 0;

  /// Toque no produto: soma uma unidade (ou 1 kg).
  CartIssue? addOne(CatalogProduct product) {
    if (product.isOutOfStock) return CartIssue.outOfStock;
    return setQuantity(product, quantityOf(product.id) + 1);
  }

  /// Zero ou menos tira o produto do carrinho.
  CartIssue? setQuantity(CatalogProduct product, double quantity) {
    final rounded = _roundQuantity(quantity);
    if (rounded <= 0) {
      remove(product.id);
      return null;
    }
    if (!product.soldByWeight && rounded != rounded.roundToDouble()) return CartIssue.invalidQuantity;
    if (rounded > product.quantity) return CartIssue.insufficientStock;
    _lines[product.id] = CartLine(product: product, quantity: rounded);
    notifyListeners();
    return null;
  }

  void remove(String productId) {
    if (_lines.remove(productId) != null) notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty && _checkoutFailure == null) return;
    _lines.clear();
    _checkoutFailure = null;
    notifyListeners();
  }

  /// Registra a venda e esvazia o carrinho. Nulo quando falhou (veja [checkoutFailure]).
  /// [customer] é obrigatório no fiado.
  Future<Sale?> checkout(PaymentMethod method, {SaleCustomer? customer}) async {
    if (_isCheckingOut || _lines.isEmpty) return null;
    _isCheckingOut = true;
    _checkoutFailure = null;
    notifyListeners();
    try {
      final sale = await _repository.register(
        SaleInput(items: _lines.values.map(_toItem).toList(growable: false), method: method, customer: customer),
      );
      _lines.clear();
      // O estoque e o saldo do fiado mudaram no servidor: avisa as telas abertas
      _stockChanges.notify(const StockSold());
      return sale;
    } on AppFailure catch (failure) {
      _checkoutFailure = failure;
      return null;
    } finally {
      _isCheckingOut = false;
      notifyListeners();
    }
  }

  SaleItem _toItem(CartLine line) => SaleItem(
    productId: line.product.id,
    name: line.product.name,
    unitPriceCents: line.product.salePriceCents,
    quantity: line.quantity,
    soldByWeight: line.product.soldByWeight,
  );

  // Peso com até 3 casas (gramas), sem resto de ponto flutuante
  double _roundQuantity(double quantity) => (quantity * 1000).round() / 1000;
}
