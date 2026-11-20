import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../theme/theme_controller.dart';

/// Escolha do tema (igual ao celular, claro ou escuro), salva no aparelho.
class ThemeMenuButton extends StatelessWidget {
  const ThemeMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<ThemeController>();
    final options = [
      (mode: ThemeMode.system, label: l10n.themeSystem, icon: Icons.brightness_auto_rounded),
      (mode: ThemeMode.light, label: l10n.themeLight, icon: Icons.light_mode_rounded),
      (mode: ThemeMode.dark, label: l10n.themeDark, icon: Icons.dark_mode_rounded),
    ];
    final current = options.firstWhere((option) => option.mode == controller.mode);

    return PopupMenuButton<ThemeMode>(
      tooltip: l10n.themeMenu,
      icon: Icon(current.icon),
      initialValue: controller.mode,
      onSelected: controller.select,
      itemBuilder: (context) => [
        for (final option in options)
          CheckedPopupMenuItem(value: option.mode, checked: option.mode == controller.mode, child: Text(option.label)),
      ],
    );
  }
}
