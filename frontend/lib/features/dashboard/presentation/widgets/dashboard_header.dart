import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../l10n/app_localizations.dart';

/// Topo do início: marca, data, configurações e saudação.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.now, required this.merchantName, required this.onSettings});

  final DateTime now;
  final String? merchantName;
  final VoidCallback onSettings;

  static const _afternoonStartsAt = 12;
  static const _eveningStartsAt = 18;

  String _greeting(AppLocalizations l10n) {
    if (now.hour < _afternoonStartsAt) return l10n.greetingMorning;
    if (now.hour < _eveningStartsAt) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  String _greetingLine(AppLocalizations l10n) {
    final name = merchantName?.trim();
    final greeting = _greeting(l10n);
    return name == null || name.isEmpty ? l10n.greetingLine(greeting) : l10n.greetingLineWithName(greeting, name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final dateLabel = toBeginningOfSentenceCase(DateFormat.MMMMEEEEd(Localizations.localeOf(context).toString()).format(now));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: context.sizes.avatar,
              height: context.sizes.avatar,
              decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(context.radius.sm)),
              alignment: Alignment.center,
              child: LeafMark(
                size: context.sizes.logoSmall,
                leftLeaf: colors.onPrimary,
                rightLeaf: colors.primaryTint,
                dot: colors.onPrimary,
              ),
            ),
            SizedBox(width: spacing.sm + 2),
            Expanded(
              child: Text(
                dateLabel,
                style: context.text.labelSmall?.copyWith(color: colors.subtle, fontWeight: FontWeight.w500),
              ),
            ),
            _HeaderButton(icon: Icons.settings_outlined, tooltip: l10n.dashboardSettings, onPressed: onSettings),
          ],
        ),
        SizedBox(height: spacing.lg + 2),
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              text: '${_greetingLine(l10n)}\n',
              children: [
                TextSpan(
                  text: l10n.greetingCallToAction,
                  style: TextStyle(color: colors.primary),
                ),
              ],
            ),
            style: context.text.displaySmall,
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: colors.ink, size: context.sizes.icon),
      style: IconButton.styleFrom(
        backgroundColor: colors.surface,
        minimumSize: Size.square(context.sizes.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radius.sm),
          side: BorderSide(color: colors.keypadBackground),
        ),
      ),
    );
  }
}
