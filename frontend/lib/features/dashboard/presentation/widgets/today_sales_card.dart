import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/stock_overview.dart';

/// Últimas vendas de hoje no início; o toque abre o detalhe da venda.
class TodaySalesCard extends StatelessWidget {
  const TodaySalesCard({super.key, required this.sales, required this.onOpen});

  final List<RecentSale> sales;
  final ValueChanged<RecentSale> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    if (sales.isEmpty) {
      return AppCard(
        padding: EdgeInsets.all(spacing.lg),
        child: Text(l10n.dashboardNoSalesToday, textAlign: TextAlign.center, style: context.text.bodyMedium),
      );
    }
    final timeFormat = DateFormat.Hm(Localizations.localeOf(context).toString());
    return AppCard(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Column(
        children: [
          for (final (index, sale) in sales.indexed) ...[
            if (index > 0) Divider(height: 1, indent: spacing.lg, endIndent: spacing.lg),
            _SaleRow(sale: sale, time: timeFormat.format(sale.createdAt), onTap: () => onOpen(sale)),
          ],
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale, required this.time, required this.onTap});

  final RecentSale sale;
  final String time;
  final VoidCallback onTap;

  String _methodLabel(AppLocalizations l10n) {
    final customer = sale.customerName;
    return switch (sale.paymentMethod) {
      'cash' => l10n.paymentCash,
      'pix' => l10n.paymentPix,
      'card' => l10n.paymentCard,
      'credit' when customer != null => l10n.saleDoneCredit(customer),
      _ => l10n.paymentCredit,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sale.productNames.join(', '), style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('$time · ${_methodLabel(l10n)}', style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: spacing.md),
            Text(MoneyFormat.format(sale.totalCents), style: context.text.titleMedium),
          ],
        ),
      ),
    );
  }
}
