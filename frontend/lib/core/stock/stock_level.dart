/// Situação do estoque calculada pelo backend (limite de "baixo" é regra do servidor).
enum StockLevel {
  ok,
  low,
  out;

  static StockLevel parse(String? value) => switch (value) {
    'low' => StockLevel.low,
    'out' => StockLevel.out,
    _ => StockLevel.ok,
  };

  /// O mesmo critério do servidor, para a cópia local sem internet. Online, vale o que a API mandar.
  static StockLevel of(double quantity, {required int lowThreshold}) {
    if (quantity <= 0) return StockLevel.out;
    return quantity <= lowThreshold ? StockLevel.low : StockLevel.ok;
  }
}
