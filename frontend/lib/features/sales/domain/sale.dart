import 'package:flutter/foundation.dart';

/// Formas de pagamento aceitas no balcão. [credit] é o fiado: a venda fica na conta do cliente.
enum PaymentMethod {
  cash('cash'),
  pix('pix'),
  card('card'),
  credit('credit');

  const PaymentMethod(this.apiValue);

  /// Valor trocado com a API (contrato com o backend).
  final String apiValue;

  static PaymentMethod? fromApi(String? value) {
    for (final method in values) {
      if (method.apiValue == value) return method;
    }
    return null;
  }
}

/// Cliente do fiado como aparece na venda: só o necessário para mostrar e abrir a conta.
@immutable
class SaleCustomer {
  const SaleCustomer({required this.id, required this.name});

  final String id;
  final String name;
}

/// Produto como aparece no catálogo da venda: só o necessário para vender.
@immutable
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.salePriceCents,
    required this.quantity,
    required this.soldByWeight,
    this.photoUrl,
  });

  final String id;
  final String name;
  final int salePriceCents;

  /// Estoque atual: unidades ou kg (até 3 casas) quando [soldByWeight].
  final double quantity;
  final bool soldByWeight;
  final String? photoUrl;

  bool get isOutOfStock => quantity <= 0;
}

@immutable
class CatalogPage {
  const CatalogPage({required this.items, required this.total});

  final List<CatalogProduct> items;
  final int total;
}

@immutable
class SaleItem {
  const SaleItem({
    required this.productId,
    required this.name,
    required this.unitPriceCents,
    required this.quantity,
    required this.soldByWeight,
  });

  /// Nulo quando o produto foi excluído depois da venda; nome e preço continuam guardados.
  final String? productId;
  final String name;

  /// Preço no momento da venda; mudar o preço do produto depois não altera vendas antigas.
  final int unitPriceCents;
  final double quantity;
  final bool soldByWeight;

  /// Só para exibição; o valor que vale é o calculado pelo servidor.
  int get subtotalCents => (unitPriceCents * quantity).round();

  SaleItem copyWith({double? quantity}) => SaleItem(
    productId: productId,
    name: name,
    unitPriceCents: unitPriceCents,
    quantity: quantity ?? this.quantity,
    soldByWeight: soldByWeight,
  );
}

@immutable
class Sale {
  const Sale({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.method,
    required this.totalCents,
    this.editedAt,
    this.customer,
    this.pendingSync = false,
  });

  /// Na venda feita sem internet, o id gerado no aparelho (o mesmo que vai ao servidor).
  final String id;
  final DateTime createdAt;
  final List<SaleItem> items;
  final PaymentMethod method;
  final int totalCents;
  final DateTime? editedAt;

  /// Só a venda fiado tem cliente.
  final SaleCustomer? customer;

  /// Feita sem internet: está guardada no aparelho e vai ao servidor quando a conexão voltar.
  /// Até lá o total é o do app (preço do catálogo); o que vale é o que o servidor calcular.
  final bool pendingSync;

  /// Produtos por peso contam como um item cada, como no carrinho.
  int get itemCount => items.fold(0, (sum, item) => sum + (item.soldByWeight ? 1 : item.quantity.round()));
}

/// Dados enviados para registrar ou editar uma venda. Preço e total não vão: quem calcula é o servidor.
@immutable
class SaleInput {
  const SaleInput({required this.items, required this.method, this.customer});

  final List<SaleItem> items;
  final PaymentMethod method;

  /// Obrigatório no fiado e ausente nas outras formas (o servidor recusa o contrário).
  final SaleCustomer? customer;
}

/// Produto que faltou quando uma venda feita sem internet chegou ao servidor. A venda foi aceita
/// (já tinha acontecido no balcão) e o estoque parou em zero.
@immutable
class StockShortfall {
  const StockShortfall({required this.name, required this.missingQuantity, required this.soldByWeight});

  final String name;
  final double missingQuantity;
  final bool soldByWeight;
}

/// Resultado do envio de uma venda que estava na fila.
@immutable
class PendingSaleReceipt {
  const PendingSaleReceipt({required this.soldAt, required this.shortfalls});

  /// Hora do balcão, para o aviso dizer de qual venda se trata.
  final DateTime soldAt;
  final List<StockShortfall> shortfalls;
}

/// Uma página do histórico, com o resumo do filtro inteiro (não só da página) calculado pelo servidor.
@immutable
class SaleHistoryPage {
  const SaleHistoryPage({required this.items, required this.total, required this.totalCents});

  final List<Sale> items;
  final int total;
  final int totalCents;
}

/// Filtro do histórico: período por dia (inclusivo), forma de pagamento e busca por produto.
@immutable
class SaleFilter {
  const SaleFilter({required this.from, required this.to, this.method, this.search = ''});

  final DateTime from;
  final DateTime to;
  final PaymentMethod? method;
  final String search;
}
