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
}
