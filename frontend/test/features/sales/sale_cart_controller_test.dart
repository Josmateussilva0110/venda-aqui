import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/features/sales/domain/sale.dart';
import 'package:vendaqui/features/sales/presentation/controllers/sale_cart_controller.dart';

import '../../support/fakes.dart';

const _rice = CatalogProduct(id: 'rice', name: 'Arroz 5 kg', salePriceCents: 2590, quantity: 3, soldByWeight: false);
const _tomato = CatalogProduct(id: 'tomato', name: 'Tomate', salePriceCents: 800, quantity: 2.5, soldByWeight: true);
const _onion = CatalogProduct(id: 'onion', name: 'Cebola', salePriceCents: 500, quantity: 0, soldByWeight: true);

/// Regras do carrinho que evitam vender o que não existe e registram a venda certa.
void main() {
  late FakeSalesRepository sales;
  late SaleCartController cart;

  setUp(() {
    sales = FakeSalesRepository(catalog: const [_rice, _tomato, _onion]);
    cart = saleCartFor(sales);
  });

  test('não passa do estoque nem aceita fração em produto por unidade', () {
    expect(cart.addOne(_onion), CartIssue.outOfStock);
    for (var i = 0; i < 3; i++) {
      expect(cart.addOne(_rice), isNull);
    }
    expect(cart.addOne(_rice), CartIssue.insufficientStock);
    expect(cart.setQuantity(_rice, 1.5), CartIssue.invalidQuantity);
    expect(cart.setQuantity(_tomato, 2.6), CartIssue.insufficientStock);
    expect(cart.setQuantity(_tomato, 1.2504), isNull);

    expect(cart.quantityOf('rice'), 3);
    expect(cart.quantityOf('tomato'), 1.25);
    expect(cart.itemCount, 4);
    expect(cart.totalCents, 3 * 2590 + 1000);
  });

  test('finalizar registra a venda com o preço da hora e esvazia o carrinho', () async {
    cart
      ..addOne(_rice)
      ..setQuantity(_tomato, 0.5);

    final sale = await cart.checkout(PaymentMethod.pix);

    expect(sale, isNotNull);
    expect(sale!.method, PaymentMethod.pix);
    expect(sale.totalCents, 2590 + 400);
    expect(sale.items.map((item) => (item.productId, item.quantity, item.unitPriceCents)), [('rice', 1, 2590), ('tomato', 0.5, 800)]);
    expect(cart.isEmpty, isTrue);
    expect(sales.sales.single.id, sale.id);
  });
}
