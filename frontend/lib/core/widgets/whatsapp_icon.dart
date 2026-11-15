import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Logo do WhatsApp nos botões que abrem a conversa. Cor e tamanho vêm do tema de ícones
/// de quem o usa (verde do app), e o único import do Font Awesome fica aqui.
class WhatsAppIcon extends StatelessWidget {
  const WhatsAppIcon({super.key});

  @override
  Widget build(BuildContext context) => const FaIcon(FontAwesomeIcons.whatsapp);
}
