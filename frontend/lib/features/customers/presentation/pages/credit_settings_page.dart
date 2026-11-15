import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/notifications/reminder_notifier.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';
import '../controllers/credit_settings_controller.dart';
import '../widgets/value_stepper.dart';

/// Prazo padrão do fiado e quando lembrar os clientes. Os limites são conferidos de novo pelo servidor.
class CreditSettingsPage extends StatelessWidget {
  const CreditSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreditSettingsController(context.read<CustomersRepository>(), context.read<ReminderNotifier>())..load(),
      child: const _CreditSettingsView(),
    );
  }
}

class _CreditSettingsView extends StatelessWidget {
  const _CreditSettingsView();

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<CreditSettingsController>().save();
      messenger.showAppToast(l10n.creditSettingsSaved);
    } on AppFailure catch (failure) {
      messenger.showAppToast(failureMessage(l10n, failure), tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<CreditSettingsController>();
    final settings = controller.settings;

    final Widget body = switch ((controller.status, settings)) {
      (CreditSettingsStatus.ready, final CreditSettings settings) => _SettingsForm(
        settings: settings,
        onChanged: controller.isSaving ? null : controller.update,
      ),
      (CreditSettingsStatus.failure, _) => ErrorView(message: failureMessage(l10n, controller.failure!), onRetry: controller.load),
      _ => const LoadingView(),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.creditSettingsTitle, onBack: () => context.pop(), buttonBackground: context.colors.surface),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(spacing.xl, spacing.md, spacing.xl, spacing.xxl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        body,
                        if (settings != null && controller.status == CreditSettingsStatus.ready) ...[
                          SizedBox(height: spacing.xl),
                          AppButton(label: l10n.creditSettingsSave, isLoading: controller.isSaving, onPressed: () => _save(context)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campos da configuração. [onChanged] nulo trava tudo enquanto salva.
class _SettingsForm extends StatelessWidget {
  const _SettingsForm({required this.settings, required this.onChanged});

  final CreditSettings settings;
  final ValueChanged<CreditSettings>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final onChanged = this.onChanged;
    final remindersOn = settings.remindersEnabled;
    String daysOrOff(int days) => days == 0 ? l10n.creditSettingsOff : l10n.daysCount(days);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.creditSettingsTerm),
        SizedBox(height: spacing.md),
        AppCard(
          padding: EdgeInsets.symmetric(vertical: spacing.xs),
          child: ValueStepper(
            label: l10n.creditSettingsTerm,
            value: settings.creditTermDays,
            min: CreditSettingsLimits.termMin,
            max: CreditSettingsLimits.termMax,
            format: l10n.daysCount,
            onChanged: onChanged == null ? null : (days) => onChanged(settings.copyWith(creditTermDays: days)),
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(l10n.creditSettingsTermHint, style: context.text.bodySmall),
        SizedBox(height: spacing.xl),
        SectionHeader(title: l10n.creditSettingsReminders),
        SizedBox(height: spacing.md),
        AppCard(
          padding: EdgeInsets.symmetric(vertical: spacing.xs),
          child: Column(
            children: [
              _SwitchRow(
                label: l10n.creditSettingsReminders,
                value: remindersOn,
                onChanged: onChanged == null ? null : (value) => onChanged(settings.copyWith(remindersEnabled: value)),
              ),
              // Desligado, os detalhes somem: não há o que configurar
              if (remindersOn) ...[
                Divider(indent: spacing.md, endIndent: spacing.md),
                ValueStepper(
                  label: l10n.creditSettingsBefore,
                  value: settings.remindDaysBefore,
                  min: 0,
                  max: CreditSettingsLimits.beforeMax,
                  format: daysOrOff,
                  onChanged: onChanged == null ? null : (days) => onChanged(settings.copyWith(remindDaysBefore: days)),
                ),
                Divider(indent: spacing.md, endIndent: spacing.md),
                _SwitchRow(
                  label: l10n.creditSettingsOnDue,
                  value: settings.remindOnDue,
                  onChanged: onChanged == null ? null : (value) => onChanged(settings.copyWith(remindOnDue: value)),
                ),
                Divider(indent: spacing.md, endIndent: spacing.md),
                ValueStepper(
                  label: l10n.creditSettingsOverdue,
                  value: settings.remindOverdueEveryDays,
                  min: 0,
                  max: CreditSettingsLimits.overdueEveryMax,
                  format: daysOrOff,
                  onChanged: onChanged == null ? null : (days) => onChanged(settings.copyWith(remindOverdueEveryDays: days)),
                ),
                Divider(indent: spacing.md, endIndent: spacing.md),
                ValueStepper(
                  label: l10n.creditSettingsHour,
                  value: settings.reminderHour,
                  min: CreditSettingsLimits.hourMin,
                  max: CreditSettingsLimits.hourMax,
                  format: l10n.creditSettingsHourValue,
                  onChanged: onChanged == null ? null : (hour) => onChanged(settings.copyWith(reminderHour: hour)),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(l10n.creditSettingsRemindersHint, style: context.text.bodySmall),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            Switch(value: value, onChanged: onChanged, activeTrackColor: context.colors.primary),
          ],
        ),
      ),
    );
  }
}
