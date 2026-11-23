import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto (Manrope, embutida em assets/fonts) mapeados no [TextTheme] do Material.
abstract final class AppTypography {
  static const fontFamily = 'Manrope';

  static TextTheme textTheme(AppColors colors) {
    final base = TextTheme(
      displayMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.12, letterSpacing: -0.85, color: colors.ink),
      displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.75, color: colors.ink),
      headlineLarge: TextStyle(
        fontSize: 54,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.6,
        color: colors.ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: colors.ink),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.45, color: colors.ink),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.ink),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.ink),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.ink),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: colors.muted),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.5, color: colors.muted),
      labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.ink),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.ink),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0, color: colors.muted),
    );
    return base;
  }

  /// Logotipo ("Vendaqui"): a mesma família, no peso mais forte e mais justa.
  static TextStyle wordmark({required double fontSize, required Color color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.03 * fontSize,
      color: color,
      height: 1.1,
    );
  }
}
