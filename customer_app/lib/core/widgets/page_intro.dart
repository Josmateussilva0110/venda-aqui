import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Bloco "etapa / título / subtítulo" do topo das telas de autenticação.
class PageIntro extends StatelessWidget {
  const PageIntro({super.key, this.eyebrow, required this.title, this.subtitle});

  final String? eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null)
          Text(
            eyebrow!,
            style: context.text.bodySmall?.copyWith(color: context.colors.primary, fontWeight: FontWeight.w600),
          ),
        if (eyebrow != null) SizedBox(height: spacing.xs),
        Semantics(header: true, child: Text(title, style: context.text.headlineSmall?.copyWith(fontSize: 24))),
        if (subtitle != null) ...[SizedBox(height: spacing.xs), Text(subtitle!, style: context.text.bodyMedium)],
      ],
    );
  }
}
