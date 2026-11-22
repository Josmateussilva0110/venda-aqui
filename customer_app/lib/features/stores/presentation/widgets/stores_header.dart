import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/page_intro.dart';
import '../../../../l10n/app_localizations.dart';

/// Topo da lista de lojas: marca, atalhos (colar link, configurações) e título.
class StoresHeader extends StatelessWidget {
  const StoresHeader({super.key, required this.onAddStore, required this.onOpenSettings});

  final VoidCallback onAddStore;
  final VoidCallback onOpenSettings;

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
            IconButton(tooltip: l10n.storesAddStore, onPressed: onAddStore, icon: const Icon(Icons.add_link_rounded)),
            IconButton(tooltip: l10n.storesSettings, onPressed: onOpenSettings, icon: const Icon(Icons.settings_outlined)),
          ],
        ),
        SizedBox(height: context.spacing.md),
        PageIntro(title: l10n.storesTitle, subtitle: l10n.storesSubtitle),
      ],
    );
  }
}
