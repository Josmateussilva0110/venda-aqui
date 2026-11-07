import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';

/// Cliente numa lista: iniciais, nome, telefone e quanto deve. [selected] marca a escolha do fiado.
class CustomerTile extends StatelessWidget {
  const CustomerTile({super.key, required this.customer, required this.onTap, this.selected, this.showAmount = false});

  final Customer customer;
  final VoidCallback onTap;

  /// Nulo quando a lista não é de escolha (sem marcador).
  final bool? selected;

  /// Valor em destaque à direita (lista de devedores); senão o saldo vai junto do telefone.
  final bool showAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final phone = PhoneFormat.fromE164(customer.phone);
    final balance = customer.owes ? l10n.customerOwes(MoneyFormat.format(customer.balanceCents)) : l10n.customerUpToDate;
    final isSelected = selected ?? false;

    return Semantics(
      selected: selected,
      button: true,
      child: AppCard(
        onTap: onTap,
        borderColor: isSelected ? colors.primary : null,
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          children: [
            ProductAvatar(name: customer.name, colorSeed: customer.id, size: context.sizes.avatar),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    showAmount ? phone : '$phone · $balance',
                    style: context.text.bodySmall?.copyWith(color: !showAmount && customer.owes ? colors.danger : null),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showAmount) ...[
              SizedBox(width: spacing.sm),
              Text(
                customer.owes ? MoneyFormat.format(customer.balanceCents) : l10n.customerUpToDate,
                style: context.text.titleSmall?.copyWith(color: customer.owes ? colors.danger : colors.successStrong),
              ),
            ],
            if (selected != null) ...[
              SizedBox(width: spacing.sm),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? colors.primary : colors.subtle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
