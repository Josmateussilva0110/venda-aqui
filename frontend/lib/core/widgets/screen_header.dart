import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/theme_context.dart';

/// Botão redondo de ícone (voltar, sair).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed, this.background});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: context.sizes.icon, color: context.colors.ink),
      style: IconButton.styleFrom(
        backgroundColor: background ?? context.colors.surfaceMuted,
        minimumSize: Size.square(context.sizes.minTouchTarget),
      ),
    );
  }
}

/// Cabeçalho com voltar à esquerda e título centralizado.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, required this.onBack, this.buttonBackground});

  final String title;
  final VoidCallback onBack;
  final Color? buttonBackground;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.sm),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: AppLocalizations.of(context).back,
            onPressed: onBack,
            background: buttonBackground,
          ),
          Expanded(
            child: Text(title, textAlign: TextAlign.center, style: context.text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          // Equilibra o botão da esquerda para o título ficar no centro
          SizedBox(width: context.sizes.minTouchTarget),
        ],
      ),
    );
  }
}
