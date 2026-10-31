/// Até duas iniciais em maiúsculas, para o quadrado do produto sem foto.
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  return words.take(2).map((word) => String.fromCharCode(word.runes.first)).join().toUpperCase();
}

/// Matiz estável (0–360) a partir de um texto, para cada produto manter a mesma cor.
double hueOf(String seed) {
  var hash = 0;
  for (final unit in seed.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return (hash % 360).toDouble();
}
