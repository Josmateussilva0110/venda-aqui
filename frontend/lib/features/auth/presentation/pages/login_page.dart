import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../controllers/login_controller.dart';
import '../controllers/session_controller.dart';
import '../widgets/auth_page_frame.dart';

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

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _phoneFormatter = PhoneInputFormatter();
  final _phoneFocus = FocusNode();
  final _pinFocus = FocusNode();
  late final TextEditingController _phoneController;
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final phone = context.read<LoginController>().phone;
    _phoneController = TextEditingController(
      text: _phoneFormatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: phone)).text,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String text) {
    final controller = context.read<LoginController>()..setPhone(text);
    // Celular completo: pula sozinho para o PIN
    if (controller.phone.length == PhoneFormat.maxDigits) _pinFocus.requestFocus();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final session = context.read<SessionController>();
    final controller = context.read<LoginController>();
    final merchant = await controller.submit();
    if (!mounted) return;
    if (merchant == null) {
      final issue = controller.issue;
      if (issue == null) return;
      showAppToast(context, switch (issue) {
        LoginMissingFields() => l10n.loginMissingFields,
        LoginFailed(:final failure) => failureMessage(l10n, failure),
      }, tone: ToastTone.error);
      // PIN errado: o controller já limpou; o campo acompanha e volta o foco para digitar de novo
      if (issue is LoginFailed) {
        _pinController.clear();
        _pinFocus.requestFocus();
      }
      return;
    }
    showAppToast(context, l10n.loginWelcome);
    session.signedIn(merchant);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LoginController>();
    final spacing = context.spacing;
    final fieldStyle = context.text.bodyLarge?.copyWith(fontSize: 17);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(spacing.xxl, spacing.xxl, spacing.xxl, spacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
          child: AutofillGroup(
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
                LabeledField(
                  label: l10n.phoneFieldLabel,
                  child: TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    autofocus: controller.phone.isEmpty,
                    onChanged: _onPhoneChanged,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_phoneFormatter],
                    autofillHints: const [AutofillHints.telephoneNumberNational],
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _pinFocus.requestFocus(),
                    style: fieldStyle,
                    decoration: InputDecoration(hintText: l10n.phonePlaceholder),
                  ),
                ),
                SizedBox(height: spacing.md + 2),
                LabeledField(
                  label: l10n.pinFieldLabel,
                  child: TextField(
                    controller: _pinController,
                    focusNode: _pinFocus,
                    autofocus: controller.phone.isNotEmpty,
                    onChanged: controller.setPin,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: AuthRules.pinMaxLength,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    style: fieldStyle,
                    decoration: const InputDecoration(counterText: ''),
                  ),
                ),
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
                AppButton(label: l10n.loginSubmit, isActive: controller.canSubmit, isLoading: controller.isSubmitting, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
