import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import 'auth_form_layout.dart';

/// Link vencido, já usado ou trocado: explica como conseguir outro.
class InviteInvalidView extends StatelessWidget {
  const InviteInvalidView({super.key, required this.onGoToLogin});

  final VoidCallback onGoToLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return AuthFormLayout(
      children: [
        Icon(Icons.link_off_rounded, size: context.sizes.iconLarge, color: context.colors.danger),
        SizedBox(height: spacing.sm),
        Semantics(header: true, child: Text(l10n.inviteInvalidTitle, style: context.text.headlineSmall)),
        SizedBox(height: spacing.xs),
        Text(l10n.inviteInvalidBody, style: context.text.bodyMedium),
        SizedBox(height: spacing.xl),
        AppButton(label: l10n.inviteGoToLogin, variant: AppButtonVariant.outlined, onPressed: onGoToLogin),
      ],
    );
  }
}
