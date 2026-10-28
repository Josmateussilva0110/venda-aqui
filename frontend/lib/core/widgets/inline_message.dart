import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Mensagem de erro curta abaixo dos campos.
class InlineError extends StatelessWidget {
  const InlineError(this.message, {super.key, this.textAlign = TextAlign.start});

  final String message;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        textAlign: textAlign,
        style: context.text.bodySmall?.copyWith(color: context.colors.danger, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
