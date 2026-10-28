import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Estilos de texto do protótipo (Plus Jakarta Sans) mapeados no [TextTheme] do Material.
abstract final class AppTypography {
  static TextTheme textTheme(AppColors colors, {required bool useGoogleFonts}) {
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
    if (!useGoogleFonts) return base;
    // Cada estilo passa pelo GoogleFonts para carregar o peso certo (700, 600…) e não um negrito sintético
    TextStyle? jakarta(TextStyle? style) => style == null ? null : GoogleFonts.plusJakartaSans(textStyle: style);
    return base.copyWith(
      displayMedium: jakarta(base.displayMedium),
      displaySmall: jakarta(base.displaySmall),
      headlineLarge: jakarta(base.headlineLarge),
      headlineMedium: jakarta(base.headlineMedium),
      headlineSmall: jakarta(base.headlineSmall),
      titleLarge: jakarta(base.titleLarge),
      titleMedium: jakarta(base.titleMedium),
      titleSmall: jakarta(base.titleSmall),
      bodyLarge: jakarta(base.bodyLarge),
      bodyMedium: jakarta(base.bodyMedium),
      bodySmall: jakarta(base.bodySmall),
      labelLarge: jakarta(base.labelLarge),
      labelMedium: jakarta(base.labelMedium),
      labelSmall: jakarta(base.labelSmall),
    );
  }

  /// Fonte da marca ("Vendaqui"), usada só no logotipo.
  static TextStyle wordmark({required double fontSize, required Color color, required bool useGoogleFonts}) {
    final style = TextStyle(fontSize: fontSize, letterSpacing: -0.01 * fontSize, color: color, height: 1.1);
    return useGoogleFonts ? GoogleFonts.dmSerifDisplay(textStyle: style) : style;
  }
}

/// Indica aos widgets se as fontes do Google podem ser usadas (desligado nos testes, que não têm rede).
@immutable
class AppFonts extends ThemeExtension<AppFonts> {
  const AppFonts({required this.useGoogleFonts});

  final bool useGoogleFonts;

  @override
  AppFonts copyWith({bool? useGoogleFonts}) => AppFonts(useGoogleFonts: useGoogleFonts ?? this.useGoogleFonts);

  @override
  AppFonts lerp(ThemeExtension<AppFonts>? other, double t) => this;
}
