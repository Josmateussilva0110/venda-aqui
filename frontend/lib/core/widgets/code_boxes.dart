import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// [CodeBoxes] preenchidas pelo teclado numérico do sistema: um campo invisível por cima das caixas
/// recebe a digitação, e tocar nas caixas abre o teclado.
class CodeField extends StatefulWidget {
  const CodeField({
    super.key,
    required this.value,
    required this.length,
    required this.semanticLabel,
    required this.onChanged,
    this.onSubmitted,
    this.obscure = false,
    this.requiredLength,
    this.autofillHints,
  });

  /// Valor vindo do controller; quando ele limpa ou troca o valor, o campo acompanha.
  final String value;
  final int length;
  final String semanticLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmitted;
  final bool obscure;
  final int? requiredLength;
  final Iterable<String>? autofillHints;

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  late final TextEditingController _text = TextEditingController(text: widget.value);
  final _focus = FocusNode();

  @override
  void didUpdateWidget(CodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _text.text) {
      _text.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CodeBoxes(
          value: widget.value,
          length: widget.length,
          semanticLabel: widget.semanticLabel,
          obscure: widget.obscure,
          requiredLength: widget.requiredLength,
        ),
        Positioned.fill(
          // Invisível, mas recebe o toque e o foco: é ele que abre o teclado do sistema
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _text,
              focusNode: _focus,
              autofocus: true,
              onChanged: widget.onChanged,
              onSubmitted: (_) => widget.onSubmitted?.call(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(widget.length)],
              autofillHints: widget.autofillHints,
              obscureText: widget.obscure,
              enableSuggestions: false,
              autocorrect: false,
              showCursor: false,
              enableInteractiveSelection: false,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration.collapsed(hintText: null),
            ),
          ),
        ),
      ],
    );
  }
}
