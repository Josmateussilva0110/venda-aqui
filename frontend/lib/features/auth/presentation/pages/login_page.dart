import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/code_boxes.dart';
import '../../../../core/widgets/display_field.dart';
import '../../../../core/widgets/inline_message.dart';
import '../../../../core/widgets/numeric_keypad.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../controllers/login_controller.dart';
import '../controllers/session_controller.dart';
import '../widgets/auth_page_frame.dart';
import '../widgets/phone_display.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.initialPhone});

  /// Telefone já digitado em outra tela (cadastro, recuperação), sem passar pela URL.
  final String? initialPhone;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginController(context.read<AuthRepository>(), initialPhone: initialPhone ?? ''),
      child: const AuthPageFrame(child: _LoginView()),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final session = context.read<SessionController>();
    final merchant = await context.read<LoginController>().submit();
    if (merchant == null || !context.mounted) return;
    showAppToast(context, l10n.loginWelcome);
    session.signedIn(merchant);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoginController>();
    return KeypadLayout(
      keypad: NumericKeypad(onKey: controller.onKey),
      content: _LoginForm(controller: controller, onSubmit: () => _submit(context)),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.controller, required this.onSubmit});

  final LoginController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final issue = controller.issue;

    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.xxl, spacing.xxl, spacing.xxl, spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: BrandLogo(markSize: context.sizes.logoMedium + 2, fontSize: 26),
          ),
          SizedBox(height: spacing.lg),
          Semantics(header: true, child: Text(l10n.loginTitle, style: context.text.headlineMedium)),
          SizedBox(height: spacing.xs),
          Text(l10n.loginSubtitle, style: context.text.bodyMedium),
          SizedBox(height: spacing.md + 2),
          DisplayField(
            label: l10n.phoneFieldLabel,
            isFocused: controller.focus == LoginField.phone,
            onTap: () => controller.focusOn(LoginField.phone),
            child: PhoneDisplay(digits: controller.phone),
          ),
          SizedBox(height: spacing.md + 2),
          DisplayField(
            label: l10n.pinFieldLabel,
            isFocused: controller.focus == LoginField.pin,
            onTap: () => controller.focusOn(LoginField.pin),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xs),
              child: PinDots(filled: controller.pin.length, length: AuthRules.pinMaxLength, requiredLength: AuthRules.pinMinLength),
            ),
          ),
          if (issue != null) ...[
            SizedBox(height: spacing.md),
            InlineError(switch (issue) {
              LoginMissingFields() => l10n.loginMissingFields,
              LoginFailed(:final failure) => failureMessage(l10n, failure),
            }),
          ],
          SizedBox(height: spacing.xs),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppTextLink(
                label: l10n.loginForgotPin,
                onPressed: () => context.push(AppRoutes.recoverPin, extra: controller.phone),
              ),
              AppTextLink(
                label: l10n.loginCreateAccount,
                color: context.colors.ink,
                onPressed: () => context.pushReplacement(AppRoutes.register),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          AppButton(label: l10n.loginSubmit, isActive: controller.canSubmit, isLoading: controller.isSubmitting, onPressed: onSubmit),
        ],
      ),
    );
  }
}
