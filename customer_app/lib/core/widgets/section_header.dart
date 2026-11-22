import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Título de seção de uma tela.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(header: true, child: Text(title, style: context.text.titleMedium));
  }
}
