import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_only.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import 'reminder_message.dart';

/// "Vence em 20/11", "Vence hoje" ou "Venceu em 03/11" (em vermelho). Vazio quando não deve.
class DueDateLabel extends StatelessWidget {
  const DueDateLabel({super.key, required this.customer, this.style});

  final Customer customer;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final due = customer.creditDueDate;
    final status = customer.dueStatusOn(DateOnly.today());
    if (due == null || status == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final date = formatDueDate(due, locale: Localizations.localeOf(context).toString());
    final (text, color) = switch (status) {
      DueStatus.upcoming => (l10n.dueDateLabel(date), colors.muted),
      DueStatus.due => (l10n.dueDateToday, colors.warning),
      DueStatus.overdue => (l10n.dueDateOverdue(date), colors.danger),
    };
    return Text(
      text,
      style: (style ?? context.text.bodySmall)?.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
