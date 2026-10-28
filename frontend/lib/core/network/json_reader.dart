/// Leitura defensiva de JSON: a resposta da API pode vir incompleta.
extension JsonReader on Map<String, dynamic> {
  String requireString(String key) {
    final value = this[key];
    if (value is String) return value;
    throw FormatException('Campo "$key" ausente ou inválido.');
  }

  String? optionalString(String key) {
    final value = this[key];
    return value is String ? value : null;
  }

  int requireInt(String key) {
    final value = this[key];
    if (value is num) return value.toInt();
    throw FormatException('Campo "$key" ausente ou inválido.');
  }

  double requireDouble(String key) {
    final value = this[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Campo "$key" ausente ou inválido.');
  }

  bool optionalBool(String key, {bool fallback = false}) {
    final value = this[key];
    return value is bool ? value : fallback;
  }

  Map<String, dynamic> requireMap(String key) {
    final value = this[key];
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Campo "$key" ausente ou inválido.');
  }

  List<Map<String, dynamic>> requireMapList(String key) {
    final value = this[key];
    if (value is! List<Object?>) throw FormatException('Campo "$key" ausente ou inválido.');
    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
