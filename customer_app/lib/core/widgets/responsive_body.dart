import 'package:flutter/material.dart';

/// Centraliza o conteúdo e limita a largura em telas largas.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.maxWidth, required this.child});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
