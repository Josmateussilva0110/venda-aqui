import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/statement_entry.dart';

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
    final quantity = QuantityFormat.format(item.quantity, soldByWeight: item.soldByWeight);
    final style = context.text.bodySmall?.copyWith(color: context.colors.inkSoft);
    return Padding(
      padding: EdgeInsets.only(top: context.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              l10n.purchaseItemLine(item.soldByWeight ? l10n.quantityKg(quantity) : l10n.quantityUnits(quantity), item.name),
              style: style,
            ),
          ),
          SizedBox(width: context.spacing.sm),
          Text(MoneyFormat.format(item.subtotalCents), style: style),
        ],
      ),
    );
  }
}
