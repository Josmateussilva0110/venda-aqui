import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import 'settlement_method_label.dart';

/// Lançamento do extrato: compra fiado (aumenta a dívida, abre a venda) ou pagamento recebido.
class StatementEntryTile extends StatelessWidget {
  const StatementEntryTile({super.key, required this.entry, required this.dateFormat, this.onTap});

  final StatementEntry entry;
  final DateFormat dateFormat;
  final VoidCallback? onTap;

  // Fatia máxima da linha para o valor; o resto fica para o título e a data
  static const _amountMaxShare = 0.4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final isSale = entry.kind == StatementEntryKind.sale;
    final method = entry.settlementMethod;
    final title = isSale ? l10n.statementSale : l10n.statementPayment(method?.label(l10n) ?? '');
    final (tint, ink) = isSale ? (colors.warningSoft, colors.warning) : (colors.successSoft, colors.successStrong);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Padding(
                  padding: EdgeInsets.all(spacing.xs + 2),
                  child: Icon(isSale ? Icons.north_east_rounded : Icons.south_west_rounded, color: ink, size: context.sizes.iconSmall),
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(dateFormat.format(entry.createdAt), style: context.text.bodySmall),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              // Encostado à direita; em tela estreita com fonte grande encolhe em vez de estourar a linha
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth * _amountMaxShare),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${isSale ? '+' : '−'} ${MoneyFormat.format(entry.amountCents)}',
                    style: context.text.titleSmall?.copyWith(color: isSale ? colors.danger : colors.successStrong),
                  ),
                ),
              ),
              if (onTap != null) Icon(Icons.chevron_right_rounded, color: colors.subtle),
            ],
          ),
        ),
      ),
    );
  }
}
