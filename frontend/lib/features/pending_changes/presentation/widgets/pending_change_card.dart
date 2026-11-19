import 'package:flutter/material.dart';

import '../../../../core/offline/outbox.dart';
import '../../../../core/offline/pending_change_text.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';

/// Uma alteração da fila. Recusada: mostra o motivo e as ações (tentar de novo ou descartar).
class PendingChangeCard extends StatelessWidget {
  const PendingChangeCard({
    super.key,
    required this.change,
    required this.text,
    required this.when,
    this.busy = false,
    this.onRetry,
    this.onDiscard,
  });

  final PendingChange change;
  final PendingChangeText text;

  /// Hora em que foi feita no aparelho, já formatada.
  final String when;
  final bool busy;
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final reason = change.reason;
    return AppCard(
      color: change.rejected ? colors.dangerCard : null,
      borderColor: change.rejected ? colors.dangerCardBorder : null,
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(text.title, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: spacing.sm),
              Text(when, style: context.text.bodySmall?.copyWith(color: colors.muted)),
            ],
          ),
          if (text.detail.isNotEmpty) ...[
            SizedBox(height: spacing.xs),
            Text(
              text.detail,
              style: context.text.bodyMedium?.copyWith(color: colors.inkSoft),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (change.rejected) ...[
            SizedBox(height: spacing.sm),
            Text(reason ?? l10n.pendingChangeRejectedFallback, style: context.text.bodyMedium?.copyWith(color: colors.dangerStrong)),
            SizedBox(height: spacing.xs),
            // Wrap: com fonte grande os dois botões descem um embaixo do outro em vez de estourar
            Wrap(
              alignment: WrapAlignment.end,
              spacing: spacing.sm,
              children: [
                TextButton(
                  onPressed: busy ? null : onDiscard,
                  style: TextButton.styleFrom(foregroundColor: colors.dangerStrong, minimumSize: Size(0, context.sizes.minTouchTarget)),
                  child: Text(l10n.pendingChangeDiscard),
                ),
                TextButton(
                  onPressed: busy ? null : onRetry,
                  style: TextButton.styleFrom(minimumSize: Size(0, context.sizes.minTouchTarget)),
                  child: Text(l10n.pendingChangeRetry),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
