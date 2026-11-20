import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';

/// Caixa de aviso discreta (ex.: "peça o link para a loja", "as outras lojas saem da consulta").
class NoticeText extends StatelessWidget {
  const NoticeText({super.key, required this.message, this.icon = Icons.info_outline_rounded, this.isWarning = false});

  final String message;
  final IconData icon;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isWarning ? colors.warningCard : colors.primarySoft,
        borderRadius: BorderRadius.circular(context.radius.lg),
        border: Border.all(color: isWarning ? colors.warningCardBorder : colors.primaryTint),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: context.sizes.iconSmall, color: isWarning ? colors.warning : colors.primary),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(message, style: context.text.bodySmall?.copyWith(color: colors.inkSoft)),
            ),
          ],
        ),
      ),
    );
  }
}
