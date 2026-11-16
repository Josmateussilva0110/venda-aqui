import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../offline/offline_status.dart';
import '../theme/theme_context.dart';
import '../utils/date_only.dart';

/// Faixa no topo quando as telas estão mostrando a cópia local por falta de internet.
/// Some sozinha na próxima resposta do servidor (ex.: puxar a lista para atualizar).
class OfflineNotice extends StatelessWidget {
  const OfflineNotice({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final savedAt = context.select<OfflineStatus, DateTime?>((status) => status.isOffline ? status.savedAt : null);
    if (savedAt == null) return child;
    return Column(
      children: [
        SafeArea(bottom: false, child: _OfflineStrip(savedAt: savedAt)),
        // A faixa já ocupou a área do recorte da tela; as páginas abaixo não precisam reservá-la de novo
        Expanded(
          child: MediaQuery.removePadding(context: context, removeTop: true, child: child),
        ),
      ],
    );
  }
}

/// Uma linha só: as telas embaixo já estão no limite da altura em celular pequeno com fonte grande.
class _OfflineStrip extends StatelessWidget {
  const _OfflineStrip({required this.savedAt});

  final DateTime savedAt;

  String _message(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final time = DateFormat.Hm(locale).format(savedAt);
    final isToday = DateOnly.daysBetween(savedAt, DateTime.now()) == 0;
    return isToday ? l10n.offlineSavedToday(time) : l10n.offlineSavedOn(DateFormat('dd/MM', locale).format(savedAt), time);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return Semantics(
      liveRegion: true,
      child: ColoredBox(
        color: colors.warningSoft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.xs),
          child: Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: colors.warning, size: context.sizes.iconSmall),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  _message(context),
                  style: context.text.bodySmall?.copyWith(color: colors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
