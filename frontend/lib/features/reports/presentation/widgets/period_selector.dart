import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/reports_controller.dart';

/// Hoje, semana, mês ou período personalizado, como um controle segmentado.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key, required this.selected, required this.onSelected});

  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final options = [
      (ReportPeriod.today, l10n.reportsToday),
      (ReportPeriod.week, l10n.reportsWeek),
      (ReportPeriod.month, l10n.reportsMonth),
      (ReportPeriod.custom, l10n.reportsCustom),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surfaceMuted, borderRadius: BorderRadius.circular(context.radius.lg)),
      child: Padding(
        padding: EdgeInsets.all(spacing.xs),
        child: Row(
          children: [
            for (final (period, label) in options)
              Expanded(
                child: Semantics(
                  selected: period == selected,
                  button: true,
                  child: Material(
                    color: period == selected ? colors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(context.radius.md),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onSelected(period),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: context.sizes.minTouchTarget - spacing.xs * 2),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: spacing.xs, vertical: spacing.xs),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelMedium?.copyWith(color: period == selected ? colors.primary : colors.inkSoft),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
