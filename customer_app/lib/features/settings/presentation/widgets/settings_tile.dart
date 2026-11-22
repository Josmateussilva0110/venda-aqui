import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';

/// Linha de opção. Com [selected] vira item de escolha única (tema); sem, é uma ação (sair).
class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.label, required this.icon, required this.onTap, this.selected, this.color});

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
