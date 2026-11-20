import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/login_method.dart';

/// Escolha entre entrar pelo telefone ou pelo CPF.
class LoginMethodSelector extends StatelessWidget {
  const LoginMethodSelector({super.key, required this.selected, required this.onChanged});

  final LoginMethod selected;
  final ValueChanged<LoginMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.loginMethodLabel,
      child: SegmentedButton<LoginMethod>(
        segments: [
          ButtonSegment(value: LoginMethod.phone, label: Text(l10n.loginByPhone), icon: const Icon(Icons.phone_iphone_rounded)),
          ButtonSegment(value: LoginMethod.cpf, label: Text(l10n.loginByCpf), icon: const Icon(Icons.badge_outlined)),
        ],
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}
