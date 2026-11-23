import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/cpf_input_formatter.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/login_method.dart';
import '../controllers/login_controller.dart';
import '../controllers/session_controller.dart';
import '../widgets/auth_form_layout.dart';
import '../widgets/auth_page_frame.dart';
import '../widgets/login_method_selector.dart';
import '../widgets/notice_text.dart';
import '../widgets/pin_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginController(context.read<AuthRepository>()),
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
  final _identifierController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinFocus = FocusNode();

  @override
  void dispose() {
    _identifierController.dispose();
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _onMethodChanged(LoginMethod method) {
    context.read<LoginController>().setMethod(method);
    _identifierController.clear();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final session = context.read<SessionController>();
    final controller = context.read<LoginController>();
    final signedIn = await controller.submit();
    if (!mounted) return;
    if (signedIn) return session.signedIn();

    final issue = controller.issue;
    if (issue == null) return;
    showAppToast(context, switch (issue) {
      LoginMissingFields() => l10n.loginMissingFields,
      LoginInvalidCpf() => l10n.loginInvalidCpf,
      LoginFailed(:final failure) => failureMessage(l10n, failure),
    }, tone: ToastTone.error);
    // PIN errado: o controller já limpou; o campo acompanha e volta o foco para digitar de novo
    if (issue is LoginFailed) {
      _pinController.clear();
      _pinFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<LoginController>();
    final spacing = context.spacing;
    final isPhone = controller.method == LoginMethod.phone;

    return AutofillGroup(
      child: AuthFormLayout(
        children: [
          Semantics(header: true, child: Text(l10n.loginTitle, style: context.text.headlineMedium)),
          SizedBox(height: spacing.xs),
          Text(l10n.loginSubtitle, style: context.text.bodyMedium),
          SizedBox(height: spacing.lg),
          LoginMethodSelector(selected: controller.method, onChanged: _onMethodChanged),
          SizedBox(height: spacing.md),
          LabeledField(
            label: isPhone ? l10n.phoneFieldLabel : l10n.cpfFieldLabel,
            child: TextField(
              // A chave troca o campo junto com o método, para a máscara e o teclado recomeçarem do zero
              key: ValueKey(controller.method),
              controller: _identifierController,
              autofocus: true,
              onChanged: controller.setIdentifier,
              keyboardType: isPhone ? TextInputType.phone : TextInputType.number,
              inputFormatters: [isPhone ? PhoneInputFormatter() : CpfInputFormatter()],
              autofillHints: isPhone ? const [AutofillHints.telephoneNumberNational] : null,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _pinFocus.requestFocus(),
              style: context.text.bodyLarge,
              decoration: InputDecoration(hintText: isPhone ? l10n.phonePlaceholder : l10n.cpfPlaceholder),
            ),
          ),
          SizedBox(height: spacing.md),
          PinField(
            label: l10n.pinFieldLabel,
            controller: _pinController,
            focusNode: _pinFocus,
            onChanged: controller.setPin,
            onSubmitted: (_) => _submit(),
          ),
          SizedBox(height: spacing.lg),
          AppButton(label: l10n.loginSubmit, isActive: controller.canSubmit, isLoading: controller.isSubmitting, onPressed: _submit),
          SizedBox(height: spacing.lg),
          NoticeText(message: l10n.loginNoAccessHint),
          SizedBox(height: spacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: AppTextLink(label: l10n.loginHaveInvite, onPressed: () => context.push(AppRoutes.pasteInvite)),
          ),
        ],
      ),
    );
  }
}
