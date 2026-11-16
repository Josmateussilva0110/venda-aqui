import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'phone_format.dart';

/// Conversa no WhatsApp pelo link público wa.me: não precisa de API nem de chave.
/// A mensagem só fica escrita na caixa; quem envia é o comerciante, no próprio WhatsApp.
abstract final class WhatsAppLink {
  static const _baseUrl = 'https://wa.me';

  /// [phone] no formato da API (+55DDDNÚMERO).
  static Uri chat(String phone, {String? message}) {
    final digits = PhoneFormat.internationalDigits(phone);
    // encodeComponent usa %20: o wa.me mostraria o "+" do encode de formulário no lugar do espaço
    final query = message == null || message.isEmpty ? '' : '?text=${Uri.encodeComponent(message)}';
    return Uri.parse('$_baseUrl/$digits$query');
  }

  /// Falso quando o aparelho não tem app nem navegador para abrir o link.
  static Future<bool> open(String phone, {String? message}) async {
    try {
      return await launchUrl(chat(phone, message: message), mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}
