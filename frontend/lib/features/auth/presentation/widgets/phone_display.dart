import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../l10n/app_localizations.dart';

/// Telefone digitado no teclado próprio, com placeholder cinza enquanto vazio.
class PhoneDisplay extends StatelessWidget {
  const PhoneDisplay({super.key, required this.digits});

  final String digits;

  @override
  Widget build(BuildContext context) {
    final isEmpty = digits.isEmpty;
    return Text(
      isEmpty ? AppLocalizations.of(context).phonePlaceholder : PhoneFormat.display(digits),
      style: context.text.titleLarge?.copyWith(color: isEmpty ? context.colors.placeholder : context.colors.ink),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
