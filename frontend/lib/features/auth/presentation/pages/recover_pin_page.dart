import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/code_boxes.dart';
import '../../../../core/widgets/display_field.dart';
import '../../../../core/widgets/inline_message.dart';
import '../../../../core/widgets/numeric_keypad.dart';
import '../../../../core/widgets/page_intro.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../controllers/recover_pin_controller.dart';
import '../controllers/session_controller.dart';
import '../widgets/auth_page_frame.dart';
import '../widgets/phone_display.dart';

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
    final sent = await context.read<RecoverPinController>().requestCode();
    if (sent && context.mounted) showAppToast(context, l10n.recoverCodeSent);
  }

  Future<void> _confirm(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final session = context.read<SessionController>();
    final merchant = await context.read<RecoverPinController>().confirm();
    if (merchant == null || !context.mounted) return;
    showAppToast(context, l10n.recoverDone);
    session.signedIn(merchant);
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
    final failure = controller.failure;
    final errorMessage = switch (controller.issue) {
      RecoverIssue.phoneInvalid => l10n.recoverPhoneInvalid,
      RecoverIssue.pinTooShort => l10n.recoverPinTooShort,
      null => failure == null ? null : failureMessage(l10n, failure),
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
            child: KeypadLayout(
              keypad: NumericKeypad(onKey: controller.onKey),
              content: Padding(
                padding: EdgeInsets.fromLTRB(spacing.xxl, spacing.lg, spacing.xxl, spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PageIntro(eyebrow: l10n.recoverStep(controller.stepNumber), title: title, subtitle: subtitle),
                    SizedBox(height: spacing.lg + 2),
                    if (phase == RecoverPhase.phone)
                      DisplayField(
                        label: l10n.phoneFieldLabel,
                        isFocused: true,
                        child: PhoneDisplay(digits: controller.phone),
                      )
                    else
                      CodeBoxes(
                        value: phase == RecoverPhase.code ? controller.code : controller.pin,
                        length: phase == RecoverPhase.code ? AuthRules.recoveryCodeLength : AuthRules.pinMaxLength,
                        requiredLength: phase == RecoverPhase.newPin ? AuthRules.pinMinLength : null,
                        obscure: phase == RecoverPhase.newPin,
                        semanticLabel: title,
                      ),
                    if (errorMessage != null) ...[SizedBox(height: spacing.lg), InlineError(errorMessage, textAlign: TextAlign.center)],
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
        ],
      ),
    );
  }
}
