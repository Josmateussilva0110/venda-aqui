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
import '../../../../core/widgets/inline_message.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/numeric_keypad.dart';
import '../../../../core/widgets/page_intro.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/step_progress.dart';
import '../../../../core/utils/keypad_input.dart';
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
                        onSubmitted: (_) => controller.submitBusiness(),
                      ),
                    ),
                    if (controller.issue != null || controller.failure != null) ...[
                      SizedBox(height: spacing.lg),
                      _BusinessError(controller: controller),
                    ],
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
                  onPressed: controller.submitBusiness,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BusinessError extends StatelessWidget {
  const _BusinessError({required this.controller});

  final RegisterController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final failure = controller.failure;
    final message = switch (controller.issue) {
      RegisterIssue.nameRequired => l10n.registerNameRequired,
      RegisterIssue.phoneInvalid => l10n.registerPhoneInvalid,
      RegisterIssue.phoneTaken => l10n.registerPhoneTaken,
      _ => failure == null ? '' : failureMessage(l10n, failure),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.md + 2, vertical: context.spacing.md),
      decoration: BoxDecoration(color: colors.dangerSurface, borderRadius: BorderRadius.circular(context.radius.sm)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: context.text.bodySmall?.copyWith(color: colors.dangerStrong, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          if (controller.issue == RegisterIssue.phoneTaken)
            AppTextLink(
              label: l10n.registerSignInWithPhone,
              onPressed: () => context.pushReplacement(AppRoutes.login, extra: controller.phone),
            ),
        ],
      ),
    );
  }
}

/// Etapa 2: criar e repetir o PIN no teclado próprio.
class _PinStep extends StatelessWidget {
  const _PinStep();

  Future<void> _onKey(BuildContext context, KeypadKey key) async {
    final l10n = AppLocalizations.of(context);
    final session = context.read<SessionController>();
    final merchant = await context.read<RegisterController>().onPinKey(key);
    if (merchant == null || !context.mounted) return;
    showAppToast(context, l10n.registerDone);
    session.signedIn(merchant);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<RegisterController>();
    final spacing = context.spacing;
    final isCreate = controller.step == RegisterStep.createPin;
    final failure = controller.failure;
    final issueMessage = switch (controller.issue) {
      RegisterIssue.pinTooShort => l10n.registerPinTooShort,
      RegisterIssue.pinMismatch => l10n.registerPinMismatch,
      _ => failure == null ? null : failureMessage(l10n, failure),
    };

    return KeypadLayout(
      keypad: NumericKeypad(onKey: (key) => _onKey(context, key)),
      content: Padding(
        padding: EdgeInsets.fromLTRB(spacing.xxl, spacing.md, spacing.xxl, spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageIntro(
              eyebrow: l10n.registerStepTwo,
              title: isCreate ? l10n.registerCreatePinTitle : l10n.registerRepeatPinTitle,
              subtitle: isCreate ? l10n.registerCreatePinSubtitle : l10n.registerRepeatPinSubtitle,
            ),
            SizedBox(height: spacing.xl),
            CodeBoxes(
              value: isCreate ? controller.pin : controller.pinRepeat,
              length: isCreate ? AuthRules.pinMaxLength : controller.pin.length,
              requiredLength: isCreate ? AuthRules.pinMinLength : null,
              obscure: true,
              semanticLabel: isCreate ? l10n.registerCreatePinTitle : l10n.registerRepeatPinTitle,
            ),
            if (issueMessage != null) ...[SizedBox(height: spacing.lg), InlineError(issueMessage, textAlign: TextAlign.center)],
            if (controller.isBusy) ...[SizedBox(height: spacing.lg), const Center(child: CircularProgressIndicator())],
            if (isCreate) ...[
              SizedBox(height: spacing.xl),
              AppButton(label: l10n.continueAction, isActive: controller.pinLongEnough, onPressed: controller.submitCreatedPin),
            ],
          ],
        ),
      ),
    );
  }
}
