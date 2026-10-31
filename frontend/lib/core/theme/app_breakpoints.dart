import 'package:flutter/widgets.dart';

enum ScreenSize { compact, medium, expanded }

/// Pontos de quebra centrais (Material 3) e larguras máximas de conteúdo.
abstract final class AppBreakpoints {
  static const double medium = 600;
  static const double expanded = 840;

  /// Largura máxima de formulários e telas de leitura em telas largas.
  static const double formMaxWidth = 520;

  /// Largura máxima de listas em telas largas.
  static const double listMaxWidth = 760;

  static ScreenSize of(double width) {
    if (width >= expanded) return ScreenSize.expanded;
    if (width >= medium) return ScreenSize.medium;
    return ScreenSize.compact;
  }
}

extension ScreenSizeContext on BuildContext {
  ScreenSize get screenSize => AppBreakpoints.of(MediaQuery.sizeOf(this).width);
}
