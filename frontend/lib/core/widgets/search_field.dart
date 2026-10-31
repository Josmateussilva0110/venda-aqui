import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, required this.hint, required this.onChanged, this.background});

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final Color? background;

  static const _maxLength = 80;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final noBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(context.radius.md), borderSide: BorderSide.none);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLength: _maxLength,
      textInputAction: TextInputAction.search,
      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: context.text.titleSmall?.copyWith(color: colors.subtle, fontWeight: FontWeight.w600),
        prefixIcon: Icon(Icons.search_rounded, color: colors.subtle, size: context.sizes.icon),
        fillColor: background ?? colors.surfaceMuted,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: context.spacing.md),
        border: noBorder,
        enabledBorder: noBorder,
        focusedBorder: noBorder,
      ),
    );
  }
}
