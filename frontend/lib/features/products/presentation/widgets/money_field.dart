import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../l10n/app_localizations.dart';

/// Campo numérico com prefixo ("R$") ou sufixo de unidade ("kg").
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.prefix,
    this.suffix,
    this.hasError = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final String? suffix;

  /// Borda vermelha; a mensagem do erro aparece no toast, não embaixo do campo.
  final bool hasError;
  final ValueChanged<String>? onChanged;

  static const _maxLength = 12;

  @override
  Widget build(BuildContext context) {
    final affixStyle = context.text.titleSmall?.copyWith(color: context.colors.muted);
    return LabeledField(
      label: label,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')), LengthLimitingTextInputFormatter(_maxLength)],
        textInputAction: TextInputAction.next,
        style: context.text.titleMedium,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: context.colors.surface,
          error: hasError ? const SizedBox.shrink() : null,
          prefixIcon: prefix == null ? null : _Affix(text: prefix!, style: affixStyle),
          suffixIcon: suffix == null ? null : _Affix(text: suffix!, style: affixStyle),
          prefixIconConstraints: const BoxConstraints(),
          suffixIconConstraints: const BoxConstraints(),
        ),
      ),
    );
  }
}

class _Affix extends StatelessWidget {
  const _Affix({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
      child: Text(text, style: style),
    );
  }
}

/// Atalho para o rótulo "R$" vindo da localização.
String currencyPrefix(BuildContext context) => AppLocalizations.of(context).currencySymbol;
