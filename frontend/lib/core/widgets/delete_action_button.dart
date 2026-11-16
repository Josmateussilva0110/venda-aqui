import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import 'screen_header.dart';

/// Lixeira no topo das telas de edição; vira um indicador de progresso enquanto exclui.
class DeleteActionButton extends StatelessWidget {
  const DeleteActionButton({super.key, required this.tooltip, required this.isDeleting, required this.onPressed});

  final String tooltip;
  final bool isDeleting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (isDeleting) {
      return SizedBox.square(
        dimension: context.sizes.minTouchTarget,
        child: Center(
          child: SizedBox.square(
            dimension: context.sizes.icon,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.danger),
          ),
        ),
      );
    }
    return CircleIconButton(
      icon: Icons.delete_outline_rounded,
      tooltip: tooltip,
      onPressed: onPressed,
      background: colors.surface,
      iconColor: colors.danger,
    );
  }
}
