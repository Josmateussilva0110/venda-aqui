import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Chip de filtro: escuro quando selecionado, com bolinha de cor opcional.
class FilterPill extends StatelessWidget {
  const FilterPill({super.key, required this.label, required this.selected, required this.onTap, this.dotColor});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.onChipActive : colors.ink;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? colors.chipActive : colors.surfaceMuted,
        borderRadius: BorderRadius.circular(context.radius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.radius.pill),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: context.sizes.minTouchTarget - context.spacing.sm),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.spacing.md + 2, vertical: context.spacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dotColor != null) ...[
                    Container(
                      width: context.sizes.statusDot,
                      height: context.sizes.statusDot,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    SizedBox(width: context.spacing.xs + 2),
                  ],
                  Text(label, style: context.text.labelMedium?.copyWith(color: foreground)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
