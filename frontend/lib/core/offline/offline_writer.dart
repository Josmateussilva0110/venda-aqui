import 'dart:async';

import 'package:uuid/uuid.dart';

import '../network/app_failure.dart';
import '../network/cancel_signal.dart';
import 'offline_reader.dart';
import 'offline_store.dart';
import 'outbox.dart';
import 'sync_state.dart';

export 'sync_state.dart';

/// Resultado de uma gravação: [value] é a resposta do servidor, nula quando foi para a fila.
typedef OfflineWrite<T> = ({T? value, SyncState state, String clientId, DateTime at});

/// Gravação com servidor primeiro e fila quando não há internet. O mesmo [clientId] vai na tentativa
/// online e na fila: se a resposta se perder, o reenvio volta como já gravado, sem duplicar.
class OfflineWriter {
  OfflineWriter(this._reader, this._outbox, {DateTime Function()? clock, String Function()? newId})
    : _clock = clock ?? DateTime.now,
      _newId = newId ?? const Uuid().v4;

  final OfflineReader _reader;
  final Outbox _outbox;
  final DateTime Function() _clock;
  final String Function() _newId;

  /// Quanto o comerciante espera (com o cliente no balcão) antes de a alteração ir para a fila.
  static const onlineBudget = Duration(seconds: 8);

  /// [online] grava no servidor. Sem internet, [queued] monta o que vai para a fila (com a hora do
  /// balcão) e [localEffects] reflete a alteração na cópia local, na mesma transação da fila.
  Future<OfflineWrite<T>> write<T>({
    required String kind,
    required Future<T> Function(String clientId, CancelSignal budget) online,
    required Map<String, dynamic> Function(String clientId, DateTime at) queued,
    Future<void> Function(OfflineStore store)? localEffects,
  }) async {
    final clientId = _newId();
    if (!_reader.recentlyOffline) {
      final budget = CancelSignal();
      final timer = Timer(onlineBudget, budget.cancel);
      try {
        final value = await online(clientId, budget);
        // A internet está de volta: aproveita para subir o que ficou na fila
        if (_outbox.pendingCount > 0) unawaited(_outbox.flush());
        return (value: value, state: SyncState.synced, clientId: clientId, at: _clock());
      } on NetworkFailure {
        _reader.noteNetworkFailure();
      } finally {
        timer.cancel();
      }
    }

    final at = _clock();
    final effects = localEffects;
    await _outbox.add(
      id: clientId,
      kind: kind,
      payload: queued(clientId, at),
      localEffects: effects == null ? null : () => effects(_reader.store),
    );
    return (value: null, state: SyncState.pending, clientId: clientId, at: at);
  }
}

/// Tradução comum da resposta do envio da fila: passageiro espera, recusa de regra fica guardada.
OutboxResult outboxResultOfFailure(AppFailure failure) {
  return switch (failure) {
    NetworkFailure() || ServerFailure() || SessionExpiredFailure() => (outcome: OutboxOutcome.retryLater, detail: null, message: null),
    RequestFailure(:final message) => (outcome: OutboxOutcome.rejected, detail: null, message: message),
    ValidationFailure(:final firstMessage) => (outcome: OutboxOutcome.rejected, detail: null, message: firstMessage),
  };
}
