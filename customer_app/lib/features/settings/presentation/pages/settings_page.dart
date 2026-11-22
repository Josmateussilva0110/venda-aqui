import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/settings_tile.dart';

/// Preferências do aparelho e conta. Novas opções entram como novas seções.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.onLogout});

  /// Encerrar a sessão é decidido pelo app, por isso chega como callback.
  final Future<void> Function() onLogout;

  Future<void> _logout(BuildContext context) async {
    // Depois de sair esta tela some (vai para o login): guarda o messenger e o aviso antes
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).settingsLoggedOut;
    await onLogout();
    messenger.showAppToast(message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final themeController = context.watch<ThemeController>();
    final options = [
      (mode: ThemeMode.system, label: l10n.themeSystem, icon: Icons.brightness_auto_rounded),
      (mode: ThemeMode.light, label: l10n.themeLight, icon: Icons.light_mode_rounded),
      (mode: ThemeMode.dark, label: l10n.themeDark, icon: Icons.dark_mode_rounded),
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(title: l10n.settingsTitle, onBack: () => context.pop(), buttonBackground: context.colors.surface),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(spacing.xl, spacing.md, spacing.xl, spacing.xxl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionHeader(title: l10n.settingsAppearance),
                        SizedBox(height: spacing.md),
                        AppCard(
                          padding: EdgeInsets.symmetric(vertical: spacing.xs),
                          child: Column(
                            children: [
                              for (final (index, option) in options.indexed) ...[
                                if (index > 0) Divider(indent: spacing.md, endIndent: spacing.md),
                                SettingsTile(
                                  label: option.label,
                                  icon: option.icon,
                                  selected: themeController.mode == option.mode,
                                  onTap: () => themeController.select(option.mode),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: spacing.sm),
                        Text(l10n.themeHint, style: context.text.bodySmall),
                        SizedBox(height: spacing.xl),
                        SectionHeader(title: l10n.settingsAccount),
                        SizedBox(height: spacing.md),
                        AppCard(
                          padding: EdgeInsets.symmetric(vertical: spacing.xs),
                          child: SettingsTile(
                            label: l10n.settingsLogout,
                            icon: Icons.logout_rounded,
                            color: context.colors.danger,
                            onTap: () => _logout(context),
                          ),
                        ),
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
