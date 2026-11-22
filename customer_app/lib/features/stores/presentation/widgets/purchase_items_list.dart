import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/statement_entry.dart';
import '../statement_labels.dart';

/// Os itens de uma compra: quantidade, nome e quanto custou cada um.
class PurchaseItemsList extends StatelessWidget {
  const PurchaseItemsList({super.key, required this.items});

  final List<PurchaseItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final item in items) _PurchaseItemRow(item: item)],
    );
  }
}

class _PurchaseItemRow extends StatelessWidget {
  const _PurchaseItemRow({required this.item});

  final PurchaseItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = context.text.bodySmall?.copyWith(color: context.colors.inkSoft);
    return Padding(
      padding: EdgeInsets.only(top: context.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(item.line(l10n), style: style)),
          SizedBox(width: context.spacing.sm),
          Text(MoneyFormat.format(item.subtotalCents), style: style),
        ],
      ),
    );
  }
}
