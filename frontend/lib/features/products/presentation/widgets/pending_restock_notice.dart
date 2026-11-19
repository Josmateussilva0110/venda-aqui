import '../../../../core/offline/outbox.dart';
import '../../../../core/offline/pending_change_text.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../l10n/app_localizations.dart';

/// Texto do aviso quando o servidor recusa uma reposição feita sem internet (ex.: produto apagado).
String? pendingRestockNotice(AppLocalizations l10n, OutboxEvent event) {
  if (event.outcome != OutboxOutcome.rejected) return null;
  final display = event.payload['display'];
  final body = event.payload['body'];
  final name = display is Map && display['name'] is String ? display['name'] as String : '';
  final soldByWeight = display is Map && display['soldByWeight'] == true;
  final quantity = body is Map && body['quantity'] is num ? (body['quantity'] as num).toDouble() : 0.0;
  return l10n.pendingRestockRejected(
    QuantityFormat.format(quantity, soldByWeight: soldByWeight),
    name,
    event.message ?? l10n.pendingChangeRejectedFallback,
  );
}

/// Como uma reposição guardada aparece na lista de pendências: produto e quantidade.
PendingChangeText pendingRestockText(AppLocalizations l10n, Map<String, dynamic> payload) {
  final body = payload['body'];
  final quantity = body is Map && body['quantity'] is num ? (body['quantity'] as num).toDouble() : 0.0;
  final soldByWeight = displayField<bool>(payload, 'soldByWeight') ?? false;
  return (
    title: l10n.pendingRestockTitle(displayField<String>(payload, 'name') ?? ''),
    detail: l10n.pendingRestockDetail(QuantityFormat.format(quantity, soldByWeight: soldByWeight)),
  );
}
