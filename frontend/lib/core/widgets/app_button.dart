import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

enum AppButtonShape { pill, rounded }

enum AppButtonVariant { primary, outlined, light }

/// Botão de ação do app. [isActive] só muda a cor (o protótipo deixa tocar e explica o que falta).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isActive = true,
    this.isLoading = false,
    this.shape = AppButtonShape.pill,
    this.variant = AppButtonVariant.primary,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isActive;
  final bool isLoading;
  final AppButtonShape shape;
  final AppButtonVariant variant;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = shape == AppButtonShape.pill ? context.radius.pill : context.radius.lg;
    final (background, foreground, border) = switch (variant) {
      AppButtonVariant.primary => (isActive ? colors.primary : colors.primaryDisabled, colors.onPrimary, null),
      AppButtonVariant.outlined => (colors.surface, colors.ink, BorderSide(color: colors.border, width: 2)),
      AppButtonVariant.light => (colors.surface, colors.ink, null),
    };
    final textStyle = (compact ? context.text.titleSmall : context.text.labelLarge)?.copyWith(color: foreground);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: compact ? context.sizes.buttonHeightCompact : context.sizes.buttonHeight,
        minWidth: context.sizes.minTouchTarget,
      ),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: border ?? BorderSide.none),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.spacing.lg, vertical: context.spacing.md),
            child: Center(
              widthFactor: 1,
              child: isLoading
                  ? SizedBox.square(
                      dimension: context.sizes.icon,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: foreground),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[Icon(icon, color: foreground, size: context.sizes.icon), SizedBox(width: context.spacing.sm)],
                        Flexible(
                          child: Text(label, style: textStyle, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Link de texto em negrito (ex.: "Esqueci meu PIN").
class AppTextLink extends StatelessWidget {
  const AppTextLink({super.key, required this.label, required this.onPressed, this.color});

  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? context.colors.primary,
        textStyle: context.text.titleSmall,
        minimumSize: Size(context.sizes.minTouchTarget, context.sizes.minTouchTarget),
        padding: EdgeInsets.symmetric(horizontal: context.spacing.xs),
      ),
      child: Text(label),
    );
  }
}
