import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';

class WeightToggleTile extends StatelessWidget {
  const WeightToggleTile({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: EdgeInsets.all(context.spacing.md + 2),
      onTap: () => onChanged(!value),
      child: MergeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.productSoldByWeight, style: context.text.titleSmall),
                  SizedBox(height: context.spacing.xxs),
                  Text(l10n.productSoldByWeightHint, style: context.text.bodySmall),
                ],
              ),
            ),
            SizedBox(width: context.spacing.md),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: context.colors.primary,
              inactiveTrackColor: context.colors.borderStrong,
              inactiveThumbColor: context.colors.surface,
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}
