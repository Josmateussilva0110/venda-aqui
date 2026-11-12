import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import 'due_date_label.dart';

/// Cliente numa lista: iniciais, nome, telefone e quanto deve. [selected] marca a escolha do fiado.
class CustomerTile extends StatelessWidget {
  const CustomerTile({super.key, required this.customer, required this.onTap, this.selected, this.showAmount = false, this.trailing});

  final Customer customer;
  final VoidCallback onTap;

  /// Nulo quando a lista não é de escolha (sem marcador).
  final bool? selected;

  /// Valor em destaque à direita (lista de devedores); senão o saldo vai junto do telefone.
  final bool showAmount;

  /// Ação extra no fim da linha (ex.: cobrar no WhatsApp), com toque próprio separado do cartão.
  final Widget? trailing;

  /// Parte da linha que o valor pode ocupar antes de encolher, para o nome sempre aparecer.
  static const _amountMaxWidthFactor = 0.4;

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
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              ProductAvatar(name: customer.name, colorSeed: customer.id, size: context.sizes.avatar),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    // Na lista de devedores o vencimento importa mais que o telefone
                    if (showAmount && customer.owes)
                      DueDateLabel(customer: customer)
                    else
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
                // Em tela estreita com fonte grande, o valor encolhe em vez de empurrar a ação para fora
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth * _amountMaxWidthFactor),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      customer.owes ? MoneyFormat.format(customer.balanceCents) : l10n.customerUpToDate,
                      style: context.text.titleSmall?.copyWith(color: customer.owes ? colors.danger : colors.successStrong),
                    ),
                  ),
                ),
              ],
              if (trailing case final action?) ...[SizedBox(width: spacing.sm), action],
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
      ),
    );
  }
}
