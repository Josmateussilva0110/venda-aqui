import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../l10n/app_localizations.dart';

/// Linha com rótulo e um número escolhido por menos/mais, entre [min] e [max].
/// [format] decide como o valor aparece ("3 dias", "9h", "Não lembrar").
class ValueStepper extends StatelessWidget {
  const ValueStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final String Function(int value) format;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final onChanged = this.onChanged;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: spacing.sm),
          IconButton(
            tooltip: l10n.stepperDecrease,
            icon: const Icon(Icons.remove_rounded),
            onPressed: onChanged == null || value <= min ? null : () => onChanged(value - 1),
          ),
          // Largura do maior texto possível evita que os botões pulem ao trocar o número
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: context.sizes.minTouchTarget * 2),
            child: Text(format(value), style: context.text.titleSmall, textAlign: TextAlign.center),
          ),
          IconButton(
            tooltip: l10n.stepperIncrease,
            icon: const Icon(Icons.add_rounded),
            onPressed: onChanged == null || value >= max ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
