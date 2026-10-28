import 'package:flutter/material.dart';

/// Espaçamentos em múltiplos usados pelo protótipo.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.xxs = 2,
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 20,
    this.xxl = 24,
    this.xxxl = 32,
    this.huge = 40,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double huge;

  @override
  AppSpacing copyWith() => this;

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) => this;
}
