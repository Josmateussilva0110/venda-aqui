import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../offline/outbox.dart';
import '../theme/theme_context.dart';
import 'app_card.dart';

/// "3 alterações esperando internet" (ou recusadas): leva à tela de pendências. Some com a fila vazia.
/// Fica no núcleo porque aparece no início e nas configurações.
class PendingChangesBanner extends StatelessWidget {
  const PendingChangesBanner({super.key, required this.onTap, this.padding = EdgeInsets.zero});

  final VoidCallback onTap;

  /// Espaço em volta, só quando a faixa aparece (com a fila vazia não sobra buraco na tela).
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final (pending, rejected) = context.select<Outbox, (int, int)>((outbox) => (outbox.pendingCount, outbox.rejectedCount));
    if (pending == 0 && rejected == 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final hasRejected = rejected > 0;
    return Padding(
      padding: padding,
      child: AppCard(
        onTap: onTap,
        color: hasRejected ? colors.dangerCard : colors.warningSoft,
        borderColor: hasRejected ? colors.dangerCardBorder : null,
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          children: [
            Icon(
              hasRejected ? Icons.error_outline_rounded : Icons.cloud_upload_outlined,
              color: hasRejected ? colors.dangerStrong : colors.warning,
              size: context.sizes.icon,
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Text(
                hasRejected ? l10n.pendingChangesBannerRejected(rejected) : l10n.pendingChangesBannerWaiting(pending),
                style: context.text.titleSmall?.copyWith(color: colors.ink),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.subtle),
          ],
        ),
      ),
    );
  }
}
