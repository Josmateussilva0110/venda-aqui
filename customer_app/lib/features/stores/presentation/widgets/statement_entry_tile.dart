import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/statement_entry.dart';
import 'purchase_items_list.dart';

/// Uma linha do extrato: compra fiado (aumenta a dívida, com os itens) ou pagamento (diminui).
class StatementEntryTile extends StatelessWidget {
  const StatementEntryTile({super.key, required this.entry});

  final StatementEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final isPayment = entry.kind == StatementKind.payment;
    final amount = MoneyFormat.format(entry.amountCents);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _EntryIcon(isPayment: isPayment),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_title(l10n), style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(AppDateFormat.moment(context, entry.createdAt), style: context.text.bodySmall),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              Text(
                isPayment ? '− $amount' : amount,
                style: context.text.titleSmall?.copyWith(color: isPayment ? colors.success : colors.ink),
              ),
            ],
          ),
          // Abaixo da linha inteira, alinhada ao título: ao lado do total ela ficaria estreita demais no celular pequeno
          if (entry.items.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.only(start: _EntryIcon.extent(context) + spacing.md, top: spacing.xs),
              child: PurchaseItemsList(items: entry.items),
            ),
        ],
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    if (entry.kind == StatementKind.purchase) return l10n.statementPurchase;
    return switch (entry.paymentMethod) {
      PaymentMethod.cash => l10n.statementPaymentWith(l10n.paymentMethodCash),
      PaymentMethod.pix => l10n.statementPaymentWith(l10n.paymentMethodPix),
      PaymentMethod.card => l10n.statementPaymentWith(l10n.paymentMethodCard),
      PaymentMethod.credit || PaymentMethod.unknown => l10n.statementPayment,
    };
  }
}

/// Círculo com o ícone de compra ou de pagamento.
class _EntryIcon extends StatelessWidget {
  const _EntryIcon({required this.isPayment});

  final bool isPayment;

  /// Largura do círculo, para alinhar os itens da compra ao título.
  static double extent(BuildContext context) => context.sizes.iconSmall + context.spacing.sm * 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: isPayment ? colors.successSoft : colors.surfaceMuted, shape: BoxShape.circle),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.sm),
        child: Icon(
          isPayment ? Icons.payments_outlined : Icons.shopping_bag_outlined,
          size: context.sizes.iconSmall,
          color: isPayment ? colors.success : colors.inkSoft,
        ),
      ),
    );
  }
}
