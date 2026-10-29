import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';

/// Atalhos para ler os tokens do tema pelo contexto.
extension ThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
  AppRadius get radius => Theme.of(this).extension<AppRadius>()!;
  AppSizes get sizes => Theme.of(this).extension<AppSizes>()!;
  TextTheme get text => Theme.of(this).textTheme;

  /// Sombra leve dos cartões brancos do protótipo.
  List<BoxShadow> get cardShadow => [
    BoxShadow(color: colors.shadow.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
    BoxShadow(color: colors.shadow.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 6)),
  ];

  /// Sombra do botão principal verde.
  List<BoxShadow> get primaryShadow => [
    BoxShadow(color: colors.primary.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 10)),
  ];
}
