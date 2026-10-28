import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Campo "falso" que recebe o foco do teclado próprio: rótulo pequeno + conteúdo.
class DisplayField extends StatelessWidget {
  const DisplayField({super.key, required this.label, required this.child, required this.isFocused, this.onTap});

  final String label;
  final Widget child;
  final bool isFocused;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.radius.lg),
      side: BorderSide(color: isFocused ? colors.primary : Colors.transparent, width: 2),
    );
    return Semantics(
      button: onTap != null,
      selected: isFocused,
      label: label,
      child: Material(
        color: colors.background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.md + 2, vertical: spacing.sm + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: spacing.xs),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
