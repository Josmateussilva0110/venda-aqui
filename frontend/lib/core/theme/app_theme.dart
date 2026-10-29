import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Ponto único de montagem do [ThemeData] a partir dos tokens.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    const radius = AppRadius();
    const sizes = AppSizes();
    const spacing = AppSpacing();
    final textTheme = AppTypography.textTheme(colors);
    final scheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.ink,
      error: colors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // Vale também para textos fora do TextTheme (campos, menus, diálogos)
      fontFamily: AppTypography.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      extensions: [colors, spacing, radius, sizes],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: colors.divider, thickness: 1, space: 1),
      // O visual do toast (pílula) fica em core/widgets/app_feedback.dart
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.background,
        hintStyle: textTheme.bodyLarge?.copyWith(color: colors.placeholder),
        contentPadding: EdgeInsets.symmetric(horizontal: spacing.md + 2, vertical: spacing.md + 2),
        border: _outline(colors.border, radius.md),
        enabledBorder: _outline(colors.border, radius.md),
        focusedBorder: _outline(colors.primary, radius.md),
        errorBorder: _outline(colors.danger, radius.md),
        focusedErrorBorder: _outline(colors.danger, radius.md),
        errorStyle: textTheme.bodySmall?.copyWith(color: colors.danger, fontWeight: FontWeight.w600),
        errorMaxLines: 3,
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: colors.primary),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primarySoft,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? colors.primary : colors.subtle,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(size: sizes.icon, color: states.contains(WidgetState.selected) ? colors.primary : colors.subtle),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primarySoft,
        selectedIconTheme: IconThemeData(color: colors.primary),
        unselectedIconTheme: IconThemeData(color: colors.subtle),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: colors.subtle, fontWeight: FontWeight.w700),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
    );
  }

  static OutlineInputBorder _outline(Color color, double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: 2),
    );
  }
}
