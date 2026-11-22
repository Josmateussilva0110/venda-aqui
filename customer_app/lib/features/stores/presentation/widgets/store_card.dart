import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/store.dart';

/// Uma loja com o que o cliente deve lá; tocar abre as movimentações.
class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, required this.onTap});

  final Store store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).storeOpenStatement(store.merchantName),
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.all(context.spacing.lg),
        child: Row(
          children: [
            Expanded(
              child: ExcludeSemantics(child: _StoreSummary(store: store)),
            ),
            SizedBox(width: context.spacing.sm),
            Icon(Icons.chevron_right_rounded, color: context.colors.subtle, size: context.sizes.icon),
          ],
        ),
      ),
    );
  }
}

/// O mesmo resumo no topo das movimentações, sem o toque.
class StoreBalance extends StatelessWidget {
  const StoreBalance({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(context.spacing.lg),
      child: _StoreSummary(store: store),
    );
  }
}

class _StoreSummary extends StatelessWidget {
  const _StoreSummary({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final dueDate = store.creditDueDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(store.merchantName, style: context.text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        SizedBox(height: context.spacing.xs),
        if (store.owes) ...[
          Text(l10n.storeOwes, style: context.text.bodySmall),
          Text(MoneyFormat.format(store.balanceCents), style: context.text.titleLarge?.copyWith(color: colors.dangerStrong)),
          if (dueDate != null) Text(l10n.storeDueOn(AppDateFormat.day(context, dueDate)), style: context.text.bodySmall),
        ] else
          Text(l10n.storeNothingOwed, style: context.text.bodyMedium?.copyWith(color: colors.success)),
      ],
    );
  }
}
