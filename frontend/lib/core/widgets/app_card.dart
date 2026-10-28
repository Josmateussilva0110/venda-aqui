import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Cartão branco arredondado com a sombra suave do protótipo.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.color, this.borderColor, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.radius.xxl);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: borderColor == null ? context.cardShadow : null),
      child: Material(
        color: color ?? context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding ?? EdgeInsets.all(context.spacing.md), child: child),
        ),
      ),
    );
  }
}
