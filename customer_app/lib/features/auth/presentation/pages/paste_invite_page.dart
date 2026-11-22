import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/invite_link.dart';
import '../widgets/auth_form_layout.dart';

/// O link do WhatsApp não abre o app sozinho: o cliente copia a mensagem da loja e cola aqui.
class PasteInvitePage extends StatefulWidget {
  const PasteInvitePage({super.key});

  @override
  State<PasteInvitePage> createState() => _PasteInvitePageState();
}

class _PasteInvitePageState extends State<PasteInvitePage> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _continue() {
    final token = InviteLink.tokenFrom(_textController.text);
    if (token == null) {
      showAppToast(context, AppLocalizations.of(context).pasteInviteNotFound, tone: ToastTone.error);
      return;
    }
    // replace: voltar da tela do PIN leva de volta ao login ou às lojas, não a esta
    context.pushReplacement(AppRoutes.inviteWithToken(token));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(backgroundColor: context.colors.surface),
      body: SafeArea(
        top: false,
        child: AuthFormLayout(
          children: [
            Semantics(header: true, child: Text(l10n.pasteInviteTitle, style: context.text.headlineMedium)),
            SizedBox(height: spacing.xs),
            Text(l10n.pasteInviteSubtitle, style: context.text.bodyMedium),
            SizedBox(height: spacing.lg),
            LabeledField(
              label: l10n.pasteInviteFieldLabel,
              child: TextField(
                controller: _textController,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                autocorrect: false,
                enableSuggestions: false,
                style: context.text.bodyMedium,
              ),
            ),
            SizedBox(height: spacing.md),
            AppButton(label: l10n.pasteInviteContinue, onPressed: _continue),
          ],
        ),
      ),
    );
  }
}
