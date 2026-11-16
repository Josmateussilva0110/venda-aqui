import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_only.dart';
import '../../../../core/utils/whatsapp_link.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/whatsapp_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';
import 'reminder_message.dart';

/// Abre a conversa com o cliente. Com [charge], busca as compras da dívida atual e deixa escrita a
/// cobrança (mensagem conforme o vencimento, com os itens). Devolve se o WhatsApp abriu.
Future<bool> openCustomerWhatsApp(
  BuildContext context,
  Customer customer, {
  bool charge = false,
  DueStatus? status,
  String? merchantName,
}) async {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  final repository = context.read<CustomersRepository>();
  // Guardado antes do await: a tela pode sair enquanto busca ou enquanto o WhatsApp abre
  final messenger = ScaffoldMessenger.of(context);

  String? message;
  if (charge) {
    final OpenAccount account;
    try {
      account = await repository.openAccount(customer.id);
    } on AppFailure catch (failure) {
      // Sem as compras a cobrança sairia incompleta: melhor avisar e deixar tentar de novo
      messenger.showAppToast(failure is NetworkFailure ? failureMessage(l10n, failure) : l10n.reminderLoadFailed, tone: ToastTone.error);
      return false;
    }
    final localStatus = DueStatus.of(balanceCents: account.balanceCents, dueDate: account.creditDueDate, today: DateOnly.today());
    message = reminderMessage(
      l10n,
      customerName: customer.name,
      account: account,
      status: status ?? localStatus ?? DueStatus.upcoming,
      merchantName: merchantName,
      locale: locale,
    );
  }

  final opened = await WhatsAppLink.open(customer.phone, message: message);
  if (!opened) messenger.showAppToast(l10n.whatsAppUnavailable, tone: ToastTone.error);
  return opened;
}

/// Atalho redondo para o WhatsApp do cliente: conversa livre ou cobrança do fiado ([charge]).
/// Enquanto busca as compras, vira um indicador de progresso (evita toque duplo).
class CustomerWhatsAppButton extends StatefulWidget {
  const CustomerWhatsAppButton({super.key, required this.customer, this.charge = false, this.merchantName});

  final Customer customer;
  final bool charge;

  /// Assina a cobrança; sem nome, a mensagem termina só com "Atenciosamente."
  final String? merchantName;

  @override
  State<CustomerWhatsAppButton> createState() => _CustomerWhatsAppButtonState();
}

class _CustomerWhatsAppButtonState extends State<CustomerWhatsAppButton> {
  bool _busy = false;

  Future<void> _open() async {
    setState(() => _busy = true);
    try {
      await openCustomerWhatsApp(context, widget.customer, charge: widget.charge, merchantName: widget.merchantName);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    if (_busy) {
      return SizedBox.square(
        dimension: context.sizes.minTouchTarget,
        child: Center(
          child: SizedBox.square(
            dimension: context.sizes.icon,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.primary),
          ),
        ),
      );
    }
    return CircleIconButton(
      iconWidget: const WhatsAppIcon(),
      tooltip: widget.charge ? l10n.whatsAppCharge : l10n.whatsAppChat,
      iconColor: colors.primary,
      background: colors.primarySoft,
      onPressed: _open,
    );
  }
}
