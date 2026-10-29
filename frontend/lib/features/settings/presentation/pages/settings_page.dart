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

/// Preferências do aparelho e conta. Novas opções entram como novas seções.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.onLogout});

  /// Encerrar a sessão é decidido pelo app, por isso chega como callback.
  final Future<void> Function() onLogout;

  Future<void> _logout(BuildContext context) async {
    // Depois de sair esta tela some (vai para as boas-vindas): guarda o messenger e o aviso antes
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
                                _SettingsTile(
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
                          child: _SettingsTile(
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

/// Linha de opção. Com [selected] vira item de escolha única (tema); sem, é uma ação (sair).
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.label, required this.icon, required this.onTap, this.selected, this.color});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool? selected;

  /// Cor do ícone e do texto; ações destrutivas usam a cor de perigo.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isSelected = selected ?? false;
    return Semantics(
      inMutuallyExclusiveGroup: selected != null,
      selected: selected,
      button: true,
      excludeSemantics: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.sizes.minTouchTarget + spacing.sm),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            child: Row(
              children: [
                Icon(icon, color: color ?? (isSelected ? colors.primary : colors.muted), size: context.sizes.icon),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.titleSmall?.copyWith(color: color ?? colors.ink),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle_rounded, color: colors.primary, size: context.sizes.icon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
