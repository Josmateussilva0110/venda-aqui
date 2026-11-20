import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/invite_info.dart';
import '../controllers/invite_controller.dart';
import '../controllers/session_controller.dart';
import 'auth_form_layout.dart';
import 'notice_text.dart';
import 'pin_field.dart';

/// PIN do link: cria o primeiro, confirma o atual ou cria um novo ("esqueci o PIN").
class InviteForm extends StatefulWidget {
  const InviteForm({super.key, required this.info});

  final InviteInfo info;

  @override
  State<InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<InviteForm> {
  final _pinController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _confirmationFocus = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmationController.dispose();
    _confirmationFocus.dispose();
    super.dispose();
  }

  void _toggleForgotPin() {
    context.read<InviteController>().toggleForgotPin();
    _clearFields();
  }

  void _clearFields() {
    _pinController.clear();
    _confirmationController.clear();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final session = context.read<SessionController>();
    final controller = context.read<InviteController>();
    final accepted = await controller.submit();
    if (!mounted) return;
    if (accepted) {
      showAppToast(context, l10n.inviteAccepted);
      session.signedIn();
      // go (e não push): o link com o token sai do histórico de navegação
      context.go(AppRoutes.stores);
      return;
    }
    final issue = controller.issue;
    if (issue == null) return;
    showAppToast(context, switch (issue) {
      InvitePinTooShort() => l10n.invitePinTooShort,
      InvitePinsDiffer() => l10n.invitePinsDiffer,
      InviteFailed(:final failure) => failureMessage(l10n, failure),
    }, tone: ToastTone.error);
    if (issue is InviteFailed) _clearFields();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<InviteController>();
    final spacing = context.spacing;
    final mode = controller.mode;

    return AuthFormLayout(
      children: [
        Semantics(header: true, child: Text(l10n.inviteTitle, style: context.text.headlineMedium)),
        SizedBox(height: spacing.xs),
        Text(l10n.inviteFrom(widget.info.merchantName, widget.info.phoneEnding), style: context.text.bodyMedium),
        SizedBox(height: spacing.lg),
        NoticeText(
          message: switch (mode) {
            InviteMode.createPin => l10n.inviteCreatePinIntro,
            InviteMode.currentPin => l10n.inviteCurrentPinIntro,
            InviteMode.resetPin => l10n.inviteResetPinIntro,
          },
          isWarning: mode == InviteMode.resetPin,
          icon: mode == InviteMode.resetPin ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
        ),
        SizedBox(height: spacing.lg),
        PinField(
          // A chave recria o campo ao trocar de modo, para o rótulo e o teclado acompanharem
          key: ValueKey(mode),
          label: controller.asksNewPin ? l10n.inviteNewPinLabel : l10n.inviteCurrentPinLabel,
          controller: _pinController,
          autofocus: true,
          onChanged: controller.setPin,
          textInputAction: controller.asksNewPin ? TextInputAction.next : TextInputAction.done,
          onSubmitted: (_) => controller.asksNewPin ? _confirmationFocus.requestFocus() : _submit(),
        ),
        if (controller.asksNewPin) ...[
          SizedBox(height: spacing.md),
          PinField(
            label: l10n.inviteConfirmPinLabel,
            controller: _confirmationController,
            focusNode: _confirmationFocus,
            onChanged: controller.setConfirmation,
            onSubmitted: (_) => _submit(),
          ),
        ],
        if (mode != InviteMode.createPin) ...[
          SizedBox(height: spacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: AppTextLink(
              label: mode == InviteMode.currentPin ? l10n.inviteForgotPin : l10n.inviteKnowPin,
              onPressed: controller.isSubmitting ? null : _toggleForgotPin,
            ),
          ),
        ],
        SizedBox(height: spacing.lg),
        AppButton(label: l10n.inviteSubmit, isActive: controller.canSubmit, isLoading: controller.isSubmitting, onPressed: _submit),
      ],
    );
  }
}
