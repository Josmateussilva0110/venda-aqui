import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/code_boxes.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/page_intro.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../controllers/recover_pin_controller.dart';
import '../controllers/session_controller.dart';
import '../widgets/auth_page_frame.dart';

class RecoverPinPage extends StatelessWidget {
  const RecoverPinPage({super.key, this.initialPhone});

  final String? initialPhone;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecoverPinController(context.read<AuthRepository>(), initialPhone: initialPhone ?? ''),
      child: const AuthPageFrame(child: _RecoverView()),
    );
  }
}

class _RecoverView extends StatelessWidget {
  const _RecoverView();

  void _back(BuildContext context, RecoverPinController controller) {
    if (controller.phase == RecoverPhase.phone) {
      context.canPop() ? context.pop() : context.go(AppRoutes.login);
    } else {
      controller.goBack();
    }
  }

  Future<void> _requestCode(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<RecoverPinController>();
    final sent = await controller.requestCode();
    if (sent) return messenger.showAppToast(l10n.recoverCodeSent);
    _toastIssue(messenger, l10n, controller);
  }

  Future<void> _confirm(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final session = context.read<SessionController>();
    final controller = context.read<RecoverPinController>();
    final merchant = await controller.confirm();
    if (merchant == null) return _toastIssue(messenger, l10n, controller);
    messenger.showAppToast(l10n.recoverDone);
    session.signedIn(merchant);
  }

  /// Os problemas da recuperação vão sempre para o toast.
  void _toastIssue(ScaffoldMessengerState messenger, AppLocalizations l10n, RecoverPinController controller) {
    final failure = controller.failure;
    final message = switch (controller.issue) {
      RecoverIssue.phoneInvalid => l10n.recoverPhoneInvalid,
      RecoverIssue.pinTooShort => l10n.recoverPinTooShort,
      null => failure == null ? null : failureMessage(l10n, failure),
    };
    if (message != null) messenger.showAppToast(message, tone: ToastTone.error);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<RecoverPinController>();
    final spacing = context.spacing;
    final phase = controller.phase;

    final (title, subtitle, buttonLabel) = switch (phase) {
      RecoverPhase.phone => (l10n.recoverPhoneTitle, l10n.recoverPhoneSubtitle, l10n.recoverSendCode),
      RecoverPhase.code => (l10n.recoverCodeTitle, l10n.recoverCodeSubtitle(PhoneFormat.display(controller.phone)), null),
      RecoverPhase.newPin => (l10n.recoverNewPinTitle, l10n.recoverNewPinSubtitle, l10n.recoverSaveNewPin),
    };

    return PopScope(
      canPop: phase == RecoverPhase.phone,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.goBack();
      },
      child: Column(
        children: [
          ScreenHeader(title: l10n.recoverTitle, onBack: () => _back(context, controller)),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(spacing.xxl, spacing.lg, spacing.xxl, spacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageIntro(eyebrow: l10n.recoverStep(controller.stepNumber), title: title, subtitle: subtitle),
                      SizedBox(height: spacing.lg + 2),
                      if (phase == RecoverPhase.phone)
                        _PhoneField(
                          initialDigits: controller.phone,
                          onChanged: controller.setPhone,
                          onSubmitted: () => _requestCode(context),
                        )
                      else
                        CodeField(
                          value: phase == RecoverPhase.code ? controller.code : controller.pin,
                          length: phase == RecoverPhase.code ? AuthRules.recoveryCodeLength : AuthRules.pinMaxLength,
                          requiredLength: phase == RecoverPhase.newPin ? AuthRules.pinMinLength : null,
                          obscure: phase == RecoverPhase.newPin,
                          semanticLabel: title,
                          onChanged: phase == RecoverPhase.code ? controller.setCode : controller.setPin,
                          onSubmitted: phase == RecoverPhase.newPin ? () => _confirm(context) : null,
                          autofillHints: phase == RecoverPhase.code ? const [AutofillHints.oneTimeCode] : null,
                        ),
                      SizedBox(height: spacing.lg + 2),
                      if (buttonLabel != null)
                        AppButton(
                          label: buttonLabel,
                          isActive: controller.canContinue,
                          isLoading: controller.isBusy,
                          onPressed: phase == RecoverPhase.phone ? () => _requestCode(context) : () => _confirm(context),
                        )
                      else
                        Center(
                          child: AppTextLink(label: l10n.recoverResendCode, onPressed: () => _requestCode(context)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Telefone com o teclado do sistema e a máscara "(00) 00000-0000".
class _PhoneField extends StatefulWidget {
  const _PhoneField({required this.initialDigits, required this.onChanged, required this.onSubmitted});

  final String initialDigits;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  final _formatter = PhoneInputFormatter();
  late final TextEditingController _controller = TextEditingController(
    text: _formatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: widget.initialDigits)).text,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LabeledField(
      label: l10n.phoneFieldLabel,
      child: TextField(
        controller: _controller,
        autofocus: true,
        onChanged: widget.onChanged,
        keyboardType: TextInputType.phone,
        inputFormatters: [_formatter],
        autofillHints: const [AutofillHints.telephoneNumberNational],
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => widget.onSubmitted(),
        style: context.text.bodyLarge?.copyWith(fontSize: 17),
        decoration: InputDecoration(hintText: l10n.phonePlaceholder),
      ),
    );
  }
}
