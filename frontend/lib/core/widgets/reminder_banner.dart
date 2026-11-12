import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/theme_context.dart';
import 'app_card.dart';

/// "3 lembretes de fiado para enviar": leva à lista de lembretes. Fica no núcleo porque aparece
/// no início e na lista de devedores.
class ReminderBanner extends StatelessWidget {
  const ReminderBanner({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(spacing.md),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: colors.primarySoft, borderRadius: BorderRadius.circular(context.radius.lg)),
            child: Padding(
              padding: EdgeInsets.all(spacing.sm),
              child: Icon(Icons.notifications_active_rounded, color: colors.primary, size: context.sizes.icon),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              AppLocalizations.of(context).remindersBanner(count),
              style: context.text.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.subtle),
        ],
      ),
    );
  }
}
