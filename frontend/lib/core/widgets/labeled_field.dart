import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Rótulo em negrito acima do campo, como no protótipo.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: context.text.labelMedium),
        SizedBox(height: context.spacing.xs + 2),
        child,
      ],
    );
  }
}
