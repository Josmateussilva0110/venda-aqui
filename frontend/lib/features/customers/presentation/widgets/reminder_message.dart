import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';

/// Datas do fiado em textos e mensagens: "20/11", com o ano só quando não é o atual.
String formatDueDate(DateTime date, {required String locale, DateTime? now}) {
  final sameYear = date.year == (now ?? DateTime.now()).year;
  return (sameYear ? DateFormat('dd/MM', locale) : DateFormat('dd/MM/yyyy', locale)).format(date);
}

/// Itens mostrados por compra; o resto vira "Mais N itens" com a soma, para a mensagem não virar um extrato.
const _maxItemsPerPurchase = 5;

/// Largura das linhas da lista. O WhatsApp usa fonte de largura variável, então a lista vai entre
/// três crases (bloco monoespaçado) para os valores alinharem. Num celular comum o balão comporta uns
/// 26 a 28 caracteres de fonte fixa (32 quebrou a linha num aparelho real); 24 deixa folga.
const _lineWidth = 22;
const _monospaceFence = '```';

/// Mensagem de cobrança no tom formal escolhido pelo comerciante, conforme a situação do vencimento,
/// com as compras da dívida atual. Saldo e vencimento vêm de [account], lidos do servidor na hora.
String reminderMessage(
  AppLocalizations l10n, {
  required String customerName,
  required OpenAccount account,
  required DueStatus status,
  required String? merchantName,
  required String locale,
}) {
  final firstName = customerName.trim().split(RegExp(r'\s+')).first;
  final amount = MoneyFormat.format(account.balanceCents);
  final dueDate = account.creditDueDate;
  final date = dueDate == null ? '' : formatDueDate(dueDate, locale: locale);
  final merchant = merchantName?.trim();
  final signature = merchant == null || merchant.isEmpty ? l10n.reminderSignatureAnonymous : l10n.reminderSignature(merchant);

  final (opening, closing) = switch (status) {
    DueStatus.upcoming => (l10n.reminderOpeningUpcoming(amount, date), l10n.reminderClosingHelp),
    DueStatus.due => (l10n.reminderOpeningDue(amount), l10n.reminderClosingHelp),
    DueStatus.overdue => (l10n.reminderOpeningOverdue(amount, date), l10n.reminderClosingNewTerm),
  };
  final purchases = _purchasesBlock(l10n, account, locale: locale);

  return ['${l10n.reminderGreeting(firstName)}\n$opening', ?purchases, '$closing\n$signature'].join('\n\n');
}

/// "*Compras:*" com a data de cada compra e os itens embaixo, cada um com o valor alinhado à direita;
/// nulo sem compras. O já pago vem em parágrafo separado, para o cliente fechar a conta: itens - pago = saldo.
String? _purchasesBlock(AppLocalizations l10n, OpenAccount account, {required String locale}) {
  if (account.purchases.isEmpty && account.earlierCount == 0) return null;
  final lines = [
    if (account.earlierCount > 0)
      _alignedLine(l10n.reminderPurchasesEarlier(account.earlierCount), MoneyFormat.format(account.earlierCents)),
    for (final purchase in account.purchases) ...[formatDueDate(purchase.createdAt, locale: locale), ..._itemLines(l10n, purchase.items)],
  ];
  final purchases = '${l10n.reminderPurchasesTitle}\n$_monospaceFence\n${lines.join('\n')}\n$_monospaceFence';
  if (account.paidCents <= 0) return purchases;
  return '$purchases\n\n${l10n.reminderPaid(MoneyFormat.format(account.paidCents))}';
}

List<String> _itemLines(AppLocalizations l10n, List<PurchasedItem> items) {
  final shown = items.take(_maxItemsPerPurchase).map((item) {
    final quantity = QuantityFormat.format(item.quantity, soldByWeight: item.soldByWeight);
    final unit = item.soldByWeight ? l10n.unitKg : l10n.unitPiece;
    final label = l10n.reminderPurchaseItem('${l10n.quantityWithUnit(quantity, unit)} ${item.name}');
    return _alignedLine(label, MoneyFormat.format(item.subtotalCents));
  });
  final hidden = items.skip(_maxItemsPerPurchase).toList();
  if (hidden.isEmpty) return shown.toList();
  // Os itens que não aparecem entram somados, para a conta continuar fechando
  final hiddenCents = hidden.fold(0, (sum, item) => sum + item.subtotalCents);
  return [...shown, _alignedLine(l10n.reminderPurchaseMoreItems(hidden.length), MoneyFormat.format(hiddenCents))];
}

/// Texto à esquerda e valor encostado à direita, numa linha de [_lineWidth] caracteres.
/// Só alinha porque a lista vai num bloco monoespaçado; texto longo é cortado com "…" para não quebrar a linha.
String _alignedLine(String label, String value) {
  final room = _lineWidth - value.characters.length - 1;
  final text = label.characters.length <= room ? label : '${label.characters.take(room - 1)}…';
  final padding = _lineWidth - text.characters.length - value.characters.length;
  return '$text${' ' * padding}$value';
}
