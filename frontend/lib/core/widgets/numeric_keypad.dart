import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_breakpoints.dart';
import '../theme/theme_context.dart';
import '../utils/keypad_input.dart';

/// Teclado numérico grande do protótipo (PIN, telefone, peso, reposição).
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({super.key, required this.onKey, this.allowDecimal = false});

  final ValueChanged<KeypadKey> onKey;
  final bool allowDecimal;

  static const _columns = 3;
  static const _digitRows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = AppLocalizations.of(context);
    final rows = <List<Widget>>[
      for (final row in _digitRows) [for (final digit in row) _KeypadButton(label: digit, onTap: () => onKey(DigitKey(digit)))],
      [
        allowDecimal
            ? _KeypadButton(
                label: KeypadInput.decimalSeparator,
                semanticLabel: l10n.decimalSeparatorKey,
                onTap: () => onKey(const DecimalKey()),
              )
            : const SizedBox.shrink(),
        _KeypadButton(label: '0', onTap: () => onKey(const DigitKey('0'))),
        _KeypadButton(icon: Icons.backspace_outlined, semanticLabel: l10n.backspace, onTap: () => onKey(const BackspaceKey())),
      ],
    ];

    return ColoredBox(
      color: context.colors.keypadBackground,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: spacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(spacing.md + 2, spacing.md - 2, spacing.md + 2, spacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, row) in rows.indexed) ...[
                    if (index > 0) SizedBox(height: spacing.sm),
                    Row(
                      children: [
                        for (var column = 0; column < _columns; column++) ...[
                          if (column > 0) SizedBox(width: spacing.sm),
                          Expanded(child: row[column]),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({this.label, this.icon, this.semanticLabel, required this.onTap});

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.radius.sm),
        shadowColor: colors.shadow,
        elevation: 0.5,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.radius.sm),
          highlightColor: colors.keyPressed,
          child: SizedBox(
            height: context.sizes.keyHeight,
            child: Center(
              child: icon != null
                  ? Icon(icon, color: colors.ink, size: context.sizes.icon)
                  : Text(label ?? '', style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Conteúdo + teclado. Em paisagem larga o teclado vai para o lado, para caber na altura.
class KeypadLayout extends StatelessWidget {
  const KeypadLayout({super.key, required this.content, required this.keypad});

  final Widget content;
  final Widget keypad;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth > constraints.maxHeight && constraints.maxWidth >= AppBreakpoints.medium;
        final scrollableContent = SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
              child: content,
            ),
          ),
        );

        if (sideBySide) {
          return Row(
            children: [
              Expanded(child: scrollableContent),
              Expanded(
                child: ColoredBox(
                  color: context.colors.keypadBackground,
                  child: Center(child: SingleChildScrollView(child: keypad)),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            Expanded(child: scrollableContent),
            keypad,
          ],
        );
      },
    );
  }
}
