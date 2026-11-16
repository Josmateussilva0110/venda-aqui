/// Como uma alteração da fila aparece na tela de pendências: o que foi e o resumo.
typedef PendingChangeText = ({String title, String detail});

/// Lê um campo do resumo (`display`) gravado junto da alteração. Alterações antigas podem não ter.
T? displayField<T>(Map<String, dynamic> payload, String key) {
  final display = payload['display'];
  if (display is! Map) return null;
  final value = display[key];
  return value is T ? value : null;
}
