import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../domain/auth_rules.dart';

/// Campo de PIN: só números, escondido e sem sugestões do teclado.
class PinField extends StatelessWidget {
  const PinField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: AuthRules.pinMaxLength,
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: context.text.bodyLarge,
        decoration: const InputDecoration(counterText: ''),
      ),
    );
  }
}
