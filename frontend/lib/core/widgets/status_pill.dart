import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Etiqueta arredondada pequena (Normal, Baixo, Esgotado…).
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.sm, vertical: context.spacing.xxs + 1),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(context.radius.pill)),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w700, fontSize: 10),
      ),
    );
  }
}
