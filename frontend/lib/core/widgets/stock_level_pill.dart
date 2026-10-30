import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../stock/stock_level.dart';
import '../theme/theme_context.dart';
import 'status_pill.dart';

/// Cores de cada situação de estoque, todas vindas do tema.
({Color pillBackground, Color pillForeground, Color cardBackground, Color cardBorder}) stockLevelColors(
  BuildContext context,
  StockLevel level,
) {
  final colors = context.colors;
  return switch (level) {
    StockLevel.out => (
      pillBackground: colors.dangerSoft,
      pillForeground: colors.dangerStrong,
      cardBackground: colors.dangerCard,
      cardBorder: colors.dangerCardBorder,
    ),
    StockLevel.low => (
      pillBackground: colors.warningSoft,
      pillForeground: colors.warning,
      cardBackground: colors.warningCard,
      cardBorder: colors.warningCardBorder,
    ),
    StockLevel.ok => (
      pillBackground: colors.successSoft,
      pillForeground: colors.success,
      cardBackground: colors.surface,
      cardBorder: colors.surface,
    ),
  };
}

String stockLevelLabel(AppLocalizations l10n, StockLevel level) => switch (level) {
  StockLevel.ok => l10n.stockLevelOk,
  StockLevel.low => l10n.stockLevelLow,
  StockLevel.out => l10n.stockLevelOut,
};

class StockLevelPill extends StatelessWidget {
  const StockLevelPill({super.key, required this.level});

  final StockLevel level;

  @override
  Widget build(BuildContext context) {
    final palette = stockLevelColors(context, level);
    return StatusPill(
      label: stockLevelLabel(AppLocalizations.of(context), level),
      background: palette.pillBackground,
      foreground: palette.pillForeground,
    );
  }
}

/// "12 kg", "4 un".
String quantityLabel(AppLocalizations l10n, String formattedQuantity, {required bool soldByWeight}) {
  return l10n.quantityWithUnit(formattedQuantity, soldByWeight ? l10n.unitKg : l10n.unitPiece);
}
