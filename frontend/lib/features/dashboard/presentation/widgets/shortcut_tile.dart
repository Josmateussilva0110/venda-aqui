import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_card.dart';

class ShortcutTile extends StatelessWidget {
  const ShortcutTile({super.key, required this.label, required this.icon, required this.tint, required this.ink, required this.onTap});

  final String label;
  final IconData icon;
  final Color tint;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = context.sizes.shortcutIcon;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: context.spacing.sm, vertical: context.spacing.md + 2),
      child: Semantics(
        button: true,
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Icon(icon, color: ink, size: context.sizes.icon),
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.text.labelSmall?.copyWith(color: context.colors.ink, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
