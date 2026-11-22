/// Lê o token do link de acesso que a loja manda pelo WhatsApp ("vendaqui-cliente://convite?token=...").
/// Aceita a mensagem inteira colada, só o link ou só o token, porque o cliente copia do jeito que der.
abstract final class InviteLink {
  // Mesma faixa que o backend aceita (base64url, 32 a 128 caracteres)
  static final _tokenParam = RegExp(r'token=([A-Za-z0-9_-]{32,128})');
  static final _bareToken = RegExp(r'^[A-Za-z0-9_-]{32,128}$');

  /// Nulo quando o texto não tem um link de acesso.
  static String? tokenFrom(String text) {
    final trimmed = text.trim();
    final fromLink = _tokenParam.firstMatch(trimmed)?.group(1);
    if (fromLink != null) return fromLink;
    return _bareToken.hasMatch(trimmed) ? trimmed : null;
  }
}
