import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_only.dart';
import '../../../../core/utils/whatsapp_link.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import 'reminder_message.dart';

/// Abre a conversa com o cliente. Com [charge], já deixa escrita a cobrança do fiado
/// (mensagem conforme o vencimento). Devolve se o WhatsApp abriu.
Future<bool> openCustomerWhatsApp(
  BuildContext context,
  Customer customer, {
  bool charge = false,
  DueStatus? status,
  String? merchantName,
}) async {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  // Guardado antes do await: a tela pode sair enquanto o WhatsApp abre
  final messenger = ScaffoldMessenger.of(context);
  final message = charge
      ? reminderMessage(
          l10n,
          customer: customer,
          status: status ?? customer.dueStatusOn(DateOnly.today()) ?? DueStatus.upcoming,
          merchantName: merchantName,
          locale: locale,
        )
      : null;
  final opened = await WhatsAppLink.open(customer.phone, message: message);
  if (!opened) messenger.showAppToast(l10n.whatsAppUnavailable, tone: ToastTone.error);
  return opened;
}

/// Atalho redondo para o WhatsApp do cliente: conversa livre ou cobrança do fiado ([charge]).
class CustomerWhatsAppButton extends StatelessWidget {
  const CustomerWhatsAppButton({super.key, required this.customer, this.charge = false, this.merchantName});

  final Customer customer;
  final bool charge;

  /// Assina a cobrança; sem nome, a mensagem termina só com "Atenciosamente."
  final String? merchantName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return CircleIconButton(
      icon: Icons.chat_rounded,
      tooltip: charge ? l10n.whatsAppCharge : l10n.whatsAppChat,
      iconColor: colors.primary,
      background: colors.primarySoft,
      onPressed: () => openCustomerWhatsApp(context, customer, charge: charge, merchantName: merchantName),
    );
  }
}
