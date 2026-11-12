import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/product_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import 'due_date_label.dart';

/// Cliente a lembrar: quanto deve, o vencimento e o botão que abre o WhatsApp com a mensagem.
class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.reminder, required this.sent, required this.onSend});

  final CreditReminder reminder;
  final bool sent;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final customer = reminder.customer;

    return AppCard(
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProductAvatar(name: customer.name, colorSeed: customer.id, size: context.sizes.avatar),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    DueDateLabel(customer: customer),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(MoneyFormat.format(customer.balanceCents), style: context.text.titleSmall?.copyWith(color: colors.danger)),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          if (sent)
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: colors.successStrong, size: context.sizes.icon),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    l10n.remindersSent,
                    style: context.text.bodyMedium?.copyWith(color: colors.successStrong),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppTextLink(label: l10n.remindersSendAgain, onPressed: onSend),
              ],
            )
          else
            AppButton(label: l10n.remindersSend, icon: Icons.chat_rounded, compact: true, onPressed: onSend),
        ],
      ),
    );
  }
}
