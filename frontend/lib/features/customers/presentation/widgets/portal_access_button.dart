import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/whatsapp_link.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/whatsapp_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';

/// Gera o link de acesso ao app do cliente e abre o WhatsApp do comerciante com a mensagem pronta.
/// Quem envia é o comerciante: é ele confirmando que esse número é mesmo do cliente.
class PortalAccessButton extends StatefulWidget {
  const PortalAccessButton({super.key, required this.customer, this.merchantName});

  final Customer customer;

  /// Nome da loja na mensagem; sem ele, a mensagem fala só "aqui da loja".
  final String? merchantName;

  @override
  State<PortalAccessButton> createState() => _PortalAccessButtonState();
}

class _PortalAccessButtonState extends State<PortalAccessButton> {
  bool _isSending = false;

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final repository = context.read<CustomersRepository>();
    // Guardado antes do await: a tela pode sair enquanto gera o link ou o WhatsApp abre
    final messenger = ScaffoldMessenger.of(context);
    final customer = widget.customer;
    setState(() => _isSending = true);
    try {
      final invite = await repository.createPortalInvite(customer.id);
      final merchantName = widget.merchantName;
      final message = merchantName == null || merchantName.isEmpty
          ? l10n.portalAccessMessageNoStore(customer.name, invite.url)
          : l10n.portalAccessMessage(customer.name, merchantName, invite.url);
      final opened = await WhatsAppLink.open(customer.phone, message: message);
      if (!opened) messenger.showAppToast(l10n.whatsAppUnavailable, tone: ToastTone.error);
    } on AppFailure catch (failure) {
      messenger.showAppToast(failureMessage(l10n, failure), tone: ToastTone.error);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: l10n.portalAccessSend,
          leading: const WhatsAppIcon(),
          variant: AppButtonVariant.outlined,
          compact: true,
          isLoading: _isSending,
          onPressed: _send,
        ),
        SizedBox(height: context.spacing.xs),
        Text(l10n.portalAccessHint, style: context.text.bodySmall),
      ],
    );
  }
}
