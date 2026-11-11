import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_breakpoints.dart';
import '../theme/theme_context.dart';
import 'app_button.dart';

/// Pede confirmação antes de uma ação. Devolve true só se o usuário confirmou
/// (tocar fora ou voltar conta como cancelar).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => _ConfirmDialog(title: title, message: message, confirmLabel: confirmLabel, destructive: destructive),
  );
  return confirmed ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.title, required this.message, required this.confirmLabel, required this.destructive});

  final String title;
  final String message;
  final String confirmLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;

    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: EdgeInsets.all(spacing.lg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.radius.xxl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.dialogMaxWidth),
        // Rola com fonte do sistema grande ou em paisagem, em vez de estourar a altura
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (destructive) ...[
                DecoratedBox(
                  decoration: BoxDecoration(color: colors.dangerSoft, shape: BoxShape.circle),
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: Icon(Icons.delete_outline_rounded, color: colors.danger, size: context.sizes.icon),
                  ),
                ),
                SizedBox(height: spacing.md),
              ],
              Text(title, textAlign: TextAlign.center, style: context.text.titleMedium),
              SizedBox(height: spacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: colors.muted),
              ),
              SizedBox(height: spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.cancel,
                      variant: AppButtonVariant.outlined,
                      compact: true,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      variant: destructive ? AppButtonVariant.danger : AppButtonVariant.primary,
                      compact: true,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
