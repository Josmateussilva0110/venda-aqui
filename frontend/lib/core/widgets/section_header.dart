import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Título de seção com link opcional à direita ("Ver todos").
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(header: true, child: Text(title, style: context.text.titleMedium)),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: context.colors.muted,
              textStyle: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
