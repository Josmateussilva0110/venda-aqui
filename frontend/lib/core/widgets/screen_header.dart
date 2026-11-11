import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/theme_context.dart';

/// Botão redondo de ícone (voltar, sair, remover).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed, this.background, this.iconColor});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: context.sizes.icon, color: iconColor ?? context.colors.ink),
      style: IconButton.styleFrom(
        backgroundColor: background ?? context.colors.surfaceMuted,
        minimumSize: Size.square(context.sizes.minTouchTarget),
      ),
    );
  }
}

/// Cabeçalho com voltar à esquerda, título centralizado e uma ação opcional à direita.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, required this.onBack, this.buttonBackground, this.action});

  final String title;
  final VoidCallback onBack;
  final Color? buttonBackground;

  /// Do tamanho de [CircleIconButton], para o título continuar no centro.
  final Widget? action;

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
          // Sem ação, o espaço vazio equilibra o botão da esquerda para o título ficar no centro
          action ?? SizedBox(width: context.sizes.minTouchTarget),
        ],
      ),
    );
  }
}
