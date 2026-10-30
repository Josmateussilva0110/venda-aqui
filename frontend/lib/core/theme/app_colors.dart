import 'package:flutter/material.dart';

/// Paleta do Vendaqui exposta como [ThemeExtension] para ser lida por contexto.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.primaryTint,
    required this.primaryDisabled,
    required this.onPrimary,
    required this.onPrimaryMuted,
    required this.leafLight,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.subtle,
    required this.placeholder,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.keypadBackground,
    required this.keyPressed,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.dashed,
    required this.danger,
    required this.dangerStrong,
    required this.dangerSoft,
    required this.dangerSurface,
    required this.dangerCard,
    required this.dangerCardBorder,
    required this.warning,
    required this.warningSoft,
    required this.warningCard,
    required this.warningCardBorder,
    required this.warningDot,
    required this.success,
    required this.successSoft,
    required this.successStrong,
    required this.neutralDot,
    required this.chipActive,
    required this.onChipActive,
    required this.boxFilled,
    required this.boxFilledBorder,
    required this.shadow,
  });

  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color primaryTint;
  final Color primaryDisabled;
  final Color onPrimary;
  final Color onPrimaryMuted;
  final Color leafLight;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color subtle;
  final Color placeholder;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color keypadBackground;
  final Color keyPressed;
  final Color border;
  final Color borderStrong;
  final Color divider;
  final Color dashed;
  final Color danger;
  final Color dangerStrong;
  final Color dangerSoft;
  final Color dangerSurface;
  final Color dangerCard;
  final Color dangerCardBorder;
  final Color warning;
  final Color warningSoft;
  final Color warningCard;
  final Color warningCardBorder;
  final Color warningDot;
  final Color success;
  final Color successSoft;
  final Color successStrong;
  final Color neutralDot;
  final Color chipActive;
  final Color onChipActive;
  final Color boxFilled;
  final Color boxFilledBorder;
  final Color shadow;

  static const AppColors light = AppColors(
    primary: Color(0xFF3E7350),
    primaryDark: Color(0xFF2E5A3D),
    primarySoft: Color(0xFFE6EFE7),
    primaryTint: Color(0xFFD2E3D6),
    primaryDisabled: Color(0xFFAFC7B6),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryMuted: Color(0xFFDDEBE0),
    leafLight: Color(0xFF7FA68A),
    ink: Color(0xFF1B2A1E),
    inkSoft: Color(0xFF4A5245),
    muted: Color(0xFF6B7262),
    subtle: Color(0xFF8C9384),
    placeholder: Color(0xFFB5BAA8),
    background: Color(0xFFF7F8F6),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF1F2EF),
    keypadBackground: Color(0xFFECEEEA),
    keyPressed: Color(0xFFD9E7DB),
    border: Color(0xFFE6E8E3),
    borderStrong: Color(0xFFDADDD5),
    divider: Color(0xFFF0F1EE),
    dashed: Color(0xFFCDD2C7),
    danger: Color(0xFFD63B30),
    dangerStrong: Color(0xFFB4291F),
    dangerSoft: Color(0xFFFDE3E1),
    dangerSurface: Color(0xFFFFF1F0),
    dangerCard: Color(0xFFFFF6F5),
    dangerCardBorder: Color(0xFFF8D3CF),
    warning: Color(0xFF8A5A00),
    warningSoft: Color(0xFFFDF0CC),
    warningCard: Color(0xFFFFFBEF),
    warningCardBorder: Color(0xFFF5E4B0),
    warningDot: Color(0xFFE0A100),
    success: Color(0xFF17723F),
    successSoft: Color(0xFFDDF3E6),
    successStrong: Color(0xFF3E8E4E),
    neutralDot: Color(0xFF9DA393),
    chipActive: Color(0xFF1B2A1E),
    onChipActive: Color(0xFFFFFFFF),
    boxFilled: Color(0xFFEEF4EF),
    boxFilledBorder: Color(0xFFB8CFBF),
    shadow: Color(0xFF142014),
  );

  // O protótipo só define o tema claro; no escuro as superfícies escurecem e o verde da marca segue com texto branco
  static const AppColors dark = AppColors(
    primary: Color(0xFF4E8A62),
    primaryDark: Color(0xFF2E5A3D),
    primarySoft: Color(0xFF243A2B),
    primaryTint: Color(0xFFD2E3D6),
    primaryDisabled: Color(0xFF3F5546),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryMuted: Color(0xFFDDEBE0),
    leafLight: Color(0xFF7FA68A),
    ink: Color(0xFFE8EDE6),
    inkSoft: Color(0xFFC3CABD),
    muted: Color(0xFF9EA694),
    subtle: Color(0xFF878F7E),
    placeholder: Color(0xFF5D6455),
    background: Color(0xFF121712),
    surface: Color(0xFF1B221C),
    surfaceMuted: Color(0xFF242C25),
    keypadBackground: Color(0xFF161C17),
    keyPressed: Color(0xFF2C4232),
    border: Color(0xFF2E372F),
    borderStrong: Color(0xFF3A443A),
    divider: Color(0xFF263027),
    dashed: Color(0xFF465046),
    danger: Color(0xFFF0776D),
    dangerStrong: Color(0xFFF0776D),
    dangerSoft: Color(0xFF3D1F1C),
    dangerSurface: Color(0xFF2E1A18),
    dangerCard: Color(0xFF261A19),
    dangerCardBorder: Color(0xFF4A2A27),
    warning: Color(0xFFE8C46A),
    warningSoft: Color(0xFF3A2F12),
    warningCard: Color(0xFF242014),
    warningCardBorder: Color(0xFF4A3E1C),
    warningDot: Color(0xFFE0A100),
    success: Color(0xFF7FD3A0),
    successSoft: Color(0xFF1C3626),
    successStrong: Color(0xFF7FD3A0),
    neutralDot: Color(0xFF6F7766),
    chipActive: Color(0xFFE8EDE6),
    onChipActive: Color(0xFF121712),
    boxFilled: Color(0xFF223127),
    boxFilledBorder: Color(0xFF4B6A54),
    shadow: Color(0xFF000000),
  );

  /// Cores do quadrado com as iniciais do produto, derivadas de um matiz estável por produto.
  ({Color background, Color foreground}) tileFor(double hue) {
    final isDark = ThemeData.estimateBrightnessForColor(background) == Brightness.dark;
    return (
      background: HSLColor.fromAHSL(1, hue, isDark ? 0.18 : 0.45, isDark ? 0.22 : 0.93).toColor(),
      foreground: HSLColor.fromAHSL(1, hue, isDark ? 0.45 : 0.42, isDark ? 0.75 : 0.32).toColor(),
    );
  }

  @override
  AppColors copyWith({Color? primary, Color? background, Color? surface, Color? ink}) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark,
      primarySoft: primarySoft,
      primaryTint: primaryTint,
      primaryDisabled: primaryDisabled,
      onPrimary: onPrimary,
      onPrimaryMuted: onPrimaryMuted,
      leafLight: leafLight,
      ink: ink ?? this.ink,
      inkSoft: inkSoft,
      muted: muted,
      subtle: subtle,
      placeholder: placeholder,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted,
      keypadBackground: keypadBackground,
      keyPressed: keyPressed,
      border: border,
      borderStrong: borderStrong,
      divider: divider,
      dashed: dashed,
      danger: danger,
      dangerStrong: dangerStrong,
      dangerSoft: dangerSoft,
      dangerSurface: dangerSurface,
      dangerCard: dangerCard,
      dangerCardBorder: dangerCardBorder,
      warning: warning,
      warningSoft: warningSoft,
      warningCard: warningCard,
      warningCardBorder: warningCardBorder,
      warningDot: warningDot,
      success: success,
      successSoft: successSoft,
      successStrong: successStrong,
      neutralDot: neutralDot,
      chipActive: chipActive,
      onChipActive: onChipActive,
      boxFilled: boxFilled,
      boxFilledBorder: boxFilledBorder,
      shadow: shadow,
    );
  }

  // Troca de tema é instantânea; interpolar dezenas de cores não traz ganho visível
  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < 0.5 ? this : other;
  }
}
