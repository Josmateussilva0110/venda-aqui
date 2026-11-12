import 'package:intl/intl.dart';

import '../../../../core/utils/money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';

/// Datas do fiado em textos e mensagens: "20/11", com o ano só quando não é o atual.
String formatDueDate(DateTime date, {required String locale, DateTime? now}) {
  final sameYear = date.year == (now ?? DateTime.now()).year;
  return (sameYear ? DateFormat('dd/MM', locale) : DateFormat('dd/MM/yyyy', locale)).format(date);
}

/// Mensagem de cobrança no tom formal escolhido pelo comerciante, conforme a situação do vencimento.
/// Sem vencimento (não deveria acontecer com quem deve) usa a de antes do vencimento, sem a data.
String reminderMessage(
  AppLocalizations l10n, {
  required Customer customer,
  required DueStatus status,
  required String? merchantName,
  required String locale,
}) {
  final firstName = customer.name.trim().split(RegExp(r'\s+')).first;
  final amount = MoneyFormat.format(customer.balanceCents);
  final dueDate = customer.creditDueDate;
  final date = dueDate == null ? '' : formatDueDate(dueDate, locale: locale);
  final merchant = merchantName?.trim();
  final signature = merchant == null || merchant.isEmpty ? l10n.reminderSignatureAnonymous : l10n.reminderSignature(merchant);

  return switch (status) {
    DueStatus.upcoming => l10n.reminderMessageUpcoming(firstName, amount, date, signature),
    DueStatus.due => l10n.reminderMessageDue(firstName, amount, signature),
    DueStatus.overdue => l10n.reminderMessageOverdue(firstName, amount, date, signature),
  };
}
