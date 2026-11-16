import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_only.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import 'due_date_label.dart';

/// Vencimento do fiado com o atalho para prolongar. [onExtend] recebe a data escolhida no calendário.
class DueDateRow extends StatelessWidget {
  const DueDateRow({super.key, required this.customer, required this.isSaving, required this.onExtend});

  final Customer customer;
  final bool isSaving;
  final ValueChanged<DateTime> onExtend;

  // O calendário só oferece o intervalo que o servidor aceita: de hoje a um ano
  Future<void> _pickDate(BuildContext context) async {
    final today = DateOnly.today();
    final due = customer.creditDueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: due == null || due.isBefore(today) ? today : due,
      firstDate: today,
      lastDate: today.add(const Duration(days: CreditSettingsLimits.dueDateMaxDays)),
      helpText: AppLocalizations.of(context).dueDateHelp,
    );
    if (picked != null) onExtend(picked);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Row(
      children: [
        Icon(Icons.event_rounded, size: context.sizes.iconSmall, color: context.colors.muted),
        SizedBox(width: spacing.xs),
        Expanded(
          child: DueDateLabel(customer: customer, style: context.text.bodyMedium),
        ),
        SizedBox(width: spacing.sm),
        AppTextLink(label: AppLocalizations.of(context).dueDateExtend, onPressed: isSaving ? null : () => _pickDate(context)),
      ],
    );
  }
}
