import 'package:flutter/material.dart';

@immutable
class AppRadius extends ThemeExtension<AppRadius> {
  const AppRadius({
    this.sm = 12,
    this.md = 14,
    this.lg = 16,
    this.xl = 18,
    this.xxl = 20,
    this.xxxl = 24,
    this.sheet = 28,
    this.pill = 999,
  });

  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double sheet;
  final double pill;

  @override
  AppRadius copyWith() => this;

  @override
  AppRadius lerp(ThemeExtension<AppRadius>? other, double t) => this;
}
