import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../theme/theme_context.dart';
import 'app_card.dart';

/// "De" e "Até" de um período personalizado, escolhidos no calendário do sistema.
class DateRangeFields extends StatelessWidget {
  const DateRangeFields({
    super.key,
    required this.from,
    required this.to,
    required this.lastDate,
    required this.onFromChanged,
    required this.onToChanged,
  });

  static final _firstDate = DateTime(2000);

  final DateTime from;
  final DateTime to;

  /// Último dia que dá para escolher (hoje: não há vendas no futuro).
  final DateTime lastDate;
  final ValueChanged<DateTime> onFromChanged;
  final ValueChanged<DateTime> onToChanged;

  Future<void> _pick(BuildContext context, DateTime initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: _firstDate, lastDate: lastDate);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = DateFormat.yMd(Localizations.localeOf(context).toString());
    return Row(
      children: [
        Expanded(
          child: _DateButton(label: l10n.historyFrom, value: format.format(from), onTap: () => _pick(context, from, onFromChanged)),
        ),
        SizedBox(width: context.spacing.sm),
        Expanded(
          child: _DateButton(label: l10n.historyTo, value: format.format(to), onTap: () => _pick(context, to, onToChanged)),
        ),
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: context.spacing.md, vertical: context.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.labelSmall),
          Text(value, style: context.text.titleSmall),
        ],
      ),
    );
  }
}
