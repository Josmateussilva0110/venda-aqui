import 'package:flutter/material.dart';

/// Tamanhos de componentes. Servem de teto: o layout ainda se adapta ao espaço disponível.
@immutable
class AppSizes extends ThemeExtension<AppSizes> {
  const AppSizes({
    this.buttonHeight = 56,
    this.buttonHeightCompact = 48,
    this.fieldHeight = 52,
    this.searchHeight = 46,
    this.iconButton = 40,
    this.minTouchTarget = 48,
    this.productTile = 56,
    this.productTileLarge = 52,
    this.avatar = 40,
    this.shortcutIcon = 44,
    this.pinBoxWidth = 42,
    this.pinBoxHeight = 52,
    this.logoSmall = 26,
    this.logoMedium = 32,
    this.photoBoxHeight = 132,
    this.welcomeImageMinHeight = 160,
    this.toggleWidth = 50,
    this.toggleHeight = 30,
    this.progressBarHeight = 5,
    this.statusDot = 8,
    this.iconSmall = 18,
    this.icon = 22,
    this.iconLarge = 26,
  });

  final double buttonHeight;
  final double buttonHeightCompact;
  final double fieldHeight;
  final double searchHeight;
  final double iconButton;
  final double minTouchTarget;
  final double productTile;
  final double productTileLarge;
  final double avatar;
  final double shortcutIcon;
  final double pinBoxWidth;
  final double pinBoxHeight;
  final double logoSmall;
  final double logoMedium;
  final double photoBoxHeight;
  final double welcomeImageMinHeight;
  final double toggleWidth;
  final double toggleHeight;
  final double progressBarHeight;
  final double statusDot;
  final double iconSmall;
  final double icon;
  final double iconLarge;

  @override
  AppSizes copyWith() => this;

  @override
  AppSizes lerp(ThemeExtension<AppSizes>? other, double t) => this;
}
