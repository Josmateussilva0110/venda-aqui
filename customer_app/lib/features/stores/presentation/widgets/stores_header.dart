import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/page_intro.dart';
import '../../../../core/widgets/theme_menu_button.dart';
import '../../../../l10n/app_localizations.dart';

/// Topo da lista de lojas: marca, botão de sair e título.
class StoresHeader extends StatelessWidget {
  const StoresHeader({super.key, required this.onAddStore, required this.onLogout});

  final VoidCallback onAddStore;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: BrandLogo(markSize: context.sizes.logoSmall, fontSize: context.text.titleLarge?.fontSize ?? context.sizes.logoSmall),
              ),
            ),
            const ThemeMenuButton(),
            IconButton(tooltip: l10n.storesAddStore, onPressed: onAddStore, icon: const Icon(Icons.add_link_rounded)),
            IconButton(tooltip: l10n.storesLogout, onPressed: onLogout, icon: const Icon(Icons.logout_rounded)),
          ],
        ),
        SizedBox(height: context.spacing.md),
        PageIntro(title: l10n.storesTitle, subtitle: l10n.storesSubtitle),
      ],
    );
  }
}
