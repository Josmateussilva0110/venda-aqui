import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../l10n/app_localizations.dart';

/// Botões − e + com a quantidade no meio, para produtos vendidos por unidade.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.quantity, required this.onDecrease, required this.onIncrease});

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          tooltip: l10n.summaryDecrease,
          background: colors.primarySoft,
          foreground: colors.primary,
          onPressed: onDecrease,
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: context.spacing.xl),
          child: Text('$quantity', textAlign: TextAlign.center, style: context.text.titleSmall),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          tooltip: l10n.summaryIncrease,
          background: colors.primary,
          foreground: colors.onPrimary,
          onPressed: onIncrease,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: context.sizes.iconSmall, color: foreground),
      style: IconButton.styleFrom(backgroundColor: background, minimumSize: Size.square(context.sizes.minTouchTarget - context.spacing.md)),
    );
  }
}
