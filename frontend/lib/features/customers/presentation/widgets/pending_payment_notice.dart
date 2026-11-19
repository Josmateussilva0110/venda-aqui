import '../../../../core/offline/outbox.dart';
import '../../../../core/offline/pending_change_text.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import 'settlement_method_label.dart';

/// Texto do aviso quando o servidor recusa um pagamento recebido sem internet (ex.: o cliente já
/// tinha pago por outro aparelho e o valor passou da dívida).
String? pendingPaymentNotice(AppLocalizations l10n, OutboxEvent event) {
  if (event.outcome != OutboxOutcome.rejected) return null;
  final display = event.payload['display'];
  final body = event.payload['body'];
  final name = display is Map && display['name'] is String ? display['name'] as String : '';
  final amount = body is Map && body['amountCents'] is int ? body['amountCents'] as int : 0;
  return l10n.pendingPaymentRejected(MoneyFormat.format(amount), name, event.message ?? l10n.pendingChangeRejectedFallback);
}

/// Como um pagamento guardado aparece na lista de pendências: valor, cliente e forma de pagamento.
PendingChangeText pendingPaymentText(AppLocalizations l10n, Map<String, dynamic> payload) {
  final body = payload['body'];
  final amount = body is Map && body['amountCents'] is int ? body['amountCents'] as int : 0;
  final method = SettlementMethod.fromApi(body is Map && body['paymentMethod'] is String ? body['paymentMethod'] as String : null);
  final name = displayField<String>(payload, 'name') ?? '';
  return (title: l10n.pendingPaymentTitle(MoneyFormat.format(amount)), detail: [name, ?method?.label(l10n)].join(' · '));
}

/// Como um cadastro de cliente guardado aparece na lista de pendências.
PendingChangeText pendingCustomerText(AppLocalizations l10n, Map<String, dynamic> payload) {
  final body = payload['body'];
  final name = body is Map && body['name'] is String ? body['name'] as String : '';
  final phone = body is Map && body['phone'] is String ? PhoneFormat.fromE164(body['phone'] as String) : '';
  return (title: l10n.pendingCustomerTitle(name), detail: phone);
}

/// Texto do aviso quando o servidor recusa um cadastro feito sem internet (ex.: telefone já cadastrado).
String? pendingCustomerNotice(AppLocalizations l10n, OutboxEvent event) {
  if (event.outcome != OutboxOutcome.rejected) return null;
  return l10n.pendingCustomerRejected(pendingCustomerText(l10n, event.payload).title, event.message ?? l10n.pendingChangeRejectedFallback);
}
