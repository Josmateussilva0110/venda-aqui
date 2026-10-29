import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/code_boxes.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/page_intro.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/step_progress.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../controllers/register_controller.dart';
import '../controllers/session_controller.dart';
import '../widgets/auth_page_frame.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterController(context.read<AuthRepository>()),
      child: const AuthPageFrame(child: _RegisterView()),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  static const _totalSteps = 2;

  void _back(BuildContext context, RegisterController controller) {
    if (controller.step == RegisterStep.business) {
      context.canPop() ? context.pop() : context.go(AppRoutes.welcome);
    } else {
      controller.goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<RegisterController>();
    final isBusiness = controller.step == RegisterStep.business;

    return PopScope(
      canPop: isBusiness,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.goBack();
      },
      child: Column(
        children: [
          ScreenHeader(title: l10n.registerTitle, onBack: () => _back(context, controller)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.spacing.xxl, vertical: context.spacing.sm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
              child: StepProgress(current: isBusiness ? 1 : _totalSteps, total: _totalSteps),
            ),
          ),
          Expanded(child: isBusiness ? const _BusinessStep() : const _PinStep()),
        ],
      ),
    );
  }
}

/// Etapa 1: nome e telefone, com o teclado do sistema.
class _BusinessStep extends StatefulWidget {
  const _BusinessStep();

  @override
  State<_BusinessStep> createState() => _BusinessStepState();
}

class _BusinessStepState extends State<_BusinessStep> {
  static const _nameMaxLength = 80;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _phoneFormatter = PhoneInputFormatter();

  @override
  void initState() {
    super.initState();
    final controller = context.read<RegisterController>();
    _nameController = TextEditingController();
    _phoneController = TextEditingController(
      text: _phoneFormatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: controller.phone)).text,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<RegisterController>();
    await controller.submitBusiness();
    _toastIssue(messenger, l10n, controller);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<RegisterController>();
    final spacing = context.spacing;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(spacing.xxl, spacing.md, spacing.xxl, spacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PageIntro(eyebrow: l10n.registerStepOne, title: l10n.registerBusinessTitle, subtitle: l10n.registerBusinessSubtitle),
                    SizedBox(height: spacing.lg),
                    LabeledField(
                      label: l10n.registerNameLabel,
                      child: TextField(
                        controller: _nameController,
                        onChanged: controller.setName,
                        maxLength: _nameMaxLength,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        style: context.text.bodyLarge?.copyWith(fontSize: 17),
                        decoration: InputDecoration(hintText: l10n.registerNameHint, counterText: ''),
                      ),
                    ),
                    SizedBox(height: spacing.lg),
                    LabeledField(
                      label: l10n.registerPhoneLabel,
                      child: TextField(
                        controller: _phoneController,
                        onChanged: controller.setPhone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneFormatter],
                        autofillHints: const [AutofillHints.telephoneNumberNational],
                        style: context.text.bodyLarge?.copyWith(fontSize: 17),
                        decoration: InputDecoration(hintText: l10n.phonePlaceholder),
                        onSubmitted: (_) => _continue(),
                      ),
                    ),
                    SizedBox(height: spacing.lg),
                    Text(l10n.registerPhoneHint, style: context.text.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          minimum: EdgeInsets.only(bottom: spacing.lg),
          child: Padding(
            padding: EdgeInsets.fromLTRB(spacing.xxl, spacing.md, spacing.xxl, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.continueAction,
                  isActive: controller.businessComplete,
                  isLoading: controller.isBusy,
                  onPressed: _continue,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mensagem do problema atual do cadastro, ou nula. Vai sempre para o toast.
String? _registerMessage(AppLocalizations l10n, RegisterController controller) {
  final failure = controller.failure;
  return switch (controller.issue) {
    RegisterIssue.nameRequired => l10n.registerNameRequired,
    RegisterIssue.phoneInvalid => l10n.registerPhoneInvalid,
    RegisterIssue.phoneTaken => l10n.registerPhoneTaken,
    RegisterIssue.pinTooShort => l10n.registerPinTooShort,
    RegisterIssue.pinMismatch => l10n.registerPinMismatch,
    null => failure == null ? null : failureMessage(l10n, failure),
  };
}

/// Mostra o problema do cadastro no toast. O messenger vem de fora porque, depois de um `await`,
/// a etapa que chamou pode já ter trocado (ex.: PIN recusado volta para a etapa 1).
void _toastIssue(ScaffoldMessengerState messenger, AppLocalizations l10n, RegisterController controller) {
  final message = _registerMessage(l10n, controller);
  if (message != null) messenger.showAppToast(message, tone: ToastTone.error);
}

/// Etapa 2: criar e repetir o PIN com o teclado numérico do sistema.
class _PinStep extends StatelessWidget {
  const _PinStep();

  Future<void> _onRepeatChanged(BuildContext context, String digits) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final session = context.read<SessionController>();
    final controller = context.read<RegisterController>();
    final merchant = await controller.setPinRepeat(digits);
    if (merchant == null) return _toastIssue(messenger, l10n, controller);
    messenger.showAppToast(l10n.registerDone);
    session.signedIn(merchant);
  }

  void _submitCreated(BuildContext context) {
    final controller = context.read<RegisterController>()..submitCreatedPin();
    _toastIssue(ScaffoldMessenger.of(context), AppLocalizations.of(context), controller);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<RegisterController>();
    final spacing = context.spacing;
    final isCreate = controller.step == RegisterStep.createPin;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(spacing.xxl, spacing.md, spacing.xxl, spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageIntro(
                eyebrow: l10n.registerStepTwo,
                title: isCreate ? l10n.registerCreatePinTitle : l10n.registerRepeatPinTitle,
                subtitle: isCreate ? l10n.registerCreatePinSubtitle : l10n.registerRepeatPinSubtitle,
              ),
              SizedBox(height: spacing.xl),
              CodeField(
                value: isCreate ? controller.pin : controller.pinRepeat,
                length: isCreate ? AuthRules.pinMaxLength : controller.pin.length,
                requiredLength: isCreate ? AuthRules.pinMinLength : null,
                obscure: true,
                semanticLabel: isCreate ? l10n.registerCreatePinTitle : l10n.registerRepeatPinTitle,
                onChanged: isCreate ? controller.setPin : (digits) => _onRepeatChanged(context, digits),
                onSubmitted: isCreate ? () => _submitCreated(context) : null,
              ),
              if (controller.isBusy) ...[SizedBox(height: spacing.lg), const Center(child: CircularProgressIndicator())],
              if (isCreate) ...[
                SizedBox(height: spacing.xl),
                AppButton(label: l10n.continueAction, isActive: controller.pinLongEnough, onPressed: () => _submitCreated(context)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
