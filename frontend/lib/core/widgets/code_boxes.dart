import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Caixas de PIN/código. Com [obscure] mostra "•" no lugar dos dígitos.
class CodeBoxes extends StatelessWidget {
  const CodeBoxes({
    super.key,
    required this.value,
    required this.length,
    required this.semanticLabel,
    this.obscure = false,
    this.requiredLength,
  });

  final String value;
  final int length;
  final bool obscure;
  final String semanticLabel;

  /// Caixas além deste número aparecem mais claras (PIN de 4 obrigatórios + 2 opcionais).
  final int? requiredLength;

  static const _obscureChar = '•';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizes = context.sizes;
    return Semantics(
      label: semanticLabel,
      value: '${value.length}/$length',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = context.spacing.sm + 2;
          // Encolhe as caixas em telas estreitas em vez de estourar a linha
          final available = (constraints.maxWidth - gap * (length - 1)) / length;
          final width = available < sizes.pinBoxWidth ? available : sizes.pinBoxWidth;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < length; index++) ...[
                if (index > 0) SizedBox(width: gap),
                _Box(
                  width: width,
                  char: index < value.length ? (obscure ? _obscureChar : value[index]) : '',
                  border: index == value.length
                      ? colors.primary
                      : index < value.length
                      ? colors.boxFilledBorder
                      : (requiredLength == null || index < requiredLength! ? colors.border : colors.divider),
                  background: index < value.length ? colors.boxFilled : colors.surface,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.width, required this.char, required this.border, required this.background});

  final double width;
  final String char;
  final Color border;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: context.sizes.pinBoxHeight),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(context.radius.sm),
        border: Border.all(color: border, width: 2),
      ),
      child: Text(char, style: context.text.headlineSmall),
    );
  }
}

/// Bolinhas do PIN no login.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled, required this.length, required this.requiredLength});

  final int filled;
  final int length;
  final int requiredLength;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = context.sizes.pinDot;
    return Wrap(
      spacing: context.spacing.md,
      children: [
        for (var index = 0; index < length; index++)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < filled ? colors.primary : Colors.transparent,
              border: Border.all(
                width: 2,
                color: index < filled ? colors.primary : (index < requiredLength ? colors.placeholder : colors.border),
              ),
            ),
          ),
      ],
    );
  }
}
