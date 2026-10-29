import 'dart:async';

/// O que mudou no estoque depois de uma ação do usuário.
sealed class StockChange {
  const StockChange(this.productId);

  final String productId;
}

final class ProductCreated extends StockChange {
  const ProductCreated(super.productId);
}

/// Edição, troca de foto ou reposição.
final class ProductUpdated extends StockChange {
  const ProductUpdated(super.productId);
}

/// Avisa as abas já abertas (início e estoque) que um produto mudou, para cada uma atualizar
/// só o que precisa em vez de recarregar tudo ao voltar de uma tela.
class StockChanges {
  final _controller = StreamController<StockChange>.broadcast();

  Stream<StockChange> get stream => _controller.stream;

  void notify(StockChange change) => _controller.add(change);

  void dispose() => _controller.close();
}
