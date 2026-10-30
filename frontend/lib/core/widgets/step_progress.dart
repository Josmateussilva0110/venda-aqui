import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Barrinhas de progresso das etapas do cadastro.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var step = 1; step <= total; step++) ...[
            if (step > 1) SizedBox(width: context.spacing.xs + 2),
            Expanded(
              child: Container(
                height: context.sizes.progressBarHeight,
                decoration: BoxDecoration(
                  color: step <= current ? colors.primary : colors.border,
                  borderRadius: BorderRadius.circular(context.radius.pill),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
