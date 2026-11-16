import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'local_database.dart';
import 'offline_store.dart';

enum OutboxOutcome {
  /// O servidor gravou (ou já tinha gravado: reenvio com o mesmo id).
  sent,

  /// Sem internet, servidor fora ou sessão a renovar: tenta de novo depois, na mesma ordem.
  retryLater,

  /// O servidor recusou de vez (ex.: produto apagado). Fica guardada para o comerciante ver.
  rejected,
}

/// Resposta de quem envia: [detail] é o que o servidor devolveu (ex.: faltas de estoque) e
/// [message] o motivo da recusa, já para mostrar ao comerciante.
typedef OutboxResult = ({OutboxOutcome outcome, Object? detail, String? message});

typedef OutboxSender = Future<OutboxResult> Function(Map<String, dynamic> payload);

/// O que aconteceu com uma alteração enviada, para a tela avisar.
@immutable
class OutboxEvent {
  const OutboxEvent({required this.kind, required this.payload, required this.outcome, this.detail, this.message});

  final String kind;
  final Map<String, dynamic> payload;
  final OutboxOutcome outcome;
  final Object? detail;
  final String? message;
}

/// Uma alteração da fila, como a tela de pendências mostra.
@immutable
class PendingChange {
  const PendingChange({
    required this.id,
    required this.kind,
    required this.payload,
    required this.createdAt,
    required this.rejected,
    this.reason,
  });

  final String id;
  final String kind;
  final Map<String, dynamic> payload;

  /// Quando foi feita no aparelho (a hora do balcão).
  final DateTime createdAt;

  /// Recusada pelo servidor: só volta para a fila se o comerciante pedir.
  final bool rejected;

  /// Motivo da recusa, já para mostrar.
  final String? reason;
}

/// Fila de alterações feitas sem internet. Cada tipo ([OutboxEntry.kind]) tem quem o envie,
/// registrado pela feature dona dele; a fila só guarda, ordena e repete.
class Outbox extends ChangeNotifier {
  Outbox(this._db, this._store, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final LocalDatabase _db;
  final OfflineStore _store;
  final DateTime Function() _clock;
  final Map<String, OutboxSender> _senders = {};
  final _events = StreamController<OutboxEvent>.broadcast();
  final _flushed = StreamController<Set<String>>.broadcast();
  final _discarded = StreamController<void>.broadcast();

  int _pendingCount = 0;
  int _rejectedCount = 0;
  Future<bool>? _flushing;

  /// Esperando para ir ao servidor.
  int get pendingCount => _pendingCount;

  /// Recusadas pelo servidor, esperando o comerciante decidir.
  int get rejectedCount => _rejectedCount;

  /// Uma alteração por evento (para avisos sobre cada uma).
  Stream<OutboxEvent> get events => _events.stream;

  /// Os tipos que subiram, uma vez por envio da fila: quem recarrega telas escuta isto, não cada alteração.
  Stream<Set<String>> get flushed => _flushed.stream;

  /// Uma recusada foi descartada: o efeito dela ainda está na cópia local, que precisa vir de novo do servidor.
  Stream<void> get discarded => _discarded.stream;

  void register(String kind, OutboxSender sender) => _senders[kind] = sender;

  /// Guarda a alteração e, na mesma transação, [localEffects] (ex.: baixar o estoque da cópia):
  /// ou as duas coisas ficam gravadas, ou nenhuma.
  Future<void> add({
    required String id,
    required String kind,
    required Map<String, dynamic> payload,
    Future<void> Function()? localEffects,
  }) async {
    final owner = await _store.owner();
    // Sem dono não há como saber de quem é a venda; o login sempre grava o dono antes
    if (owner == null) throw StateError('Outbox sem dono: nenhuma sessão gravada.');
    final now = _clock();
    await _db.transaction(() async {
      await _db
          .into(_db.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              id: id,
              ownerId: owner.id,
              kind: kind,
              payload: jsonEncode(payload),
              createdAt: now,
              sequence: Value(now.microsecondsSinceEpoch),
            ),
          );
      await localEffects?.call();
    });
    await refreshCounts();
  }

  /// Envia o que está pendente, na ordem em que aconteceu. Para no primeiro "tenta depois",
  /// para não passar uma alteração à frente de outra. Devolve se não sobrou nada pendente.
  Future<bool> flush() {
    // Gatilhos ao mesmo tempo (volta da internet e volta ao app) compartilham o mesmo envio
    return _flushing ??= _flush().whenComplete(() => _flushing = null);
  }

  Future<bool> _flush() async {
    final owner = await _store.owner();
    if (owner == null) return true;
    final sentKinds = <String>{};
    try {
      while (true) {
        final entry = await _nextPending(owner.id);
        if (entry == null) return true;
        final sender = _senders[entry.kind];
        if (sender == null) return false;

        final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
        final result = await sender(payload);
        await _record(entry, result);
        if (result.outcome == OutboxOutcome.sent) sentKinds.add(entry.kind);
        _events.add(
          OutboxEvent(kind: entry.kind, payload: payload, outcome: result.outcome, detail: result.detail, message: result.message),
        );
        if (result.outcome == OutboxOutcome.retryLater) return false;
      }
    } finally {
      await refreshCounts();
      if (sentKinds.isNotEmpty) _flushed.add(sentKinds);
    }
  }

  Future<OutboxEntry?> _nextPending(String ownerId) {
    final query = _db.select(_db.outboxEntries)
      ..where((row) => row.ownerId.equals(ownerId) & row.rejected.equals(false))
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt), (row) => OrderingTerm.asc(row.sequence), (row) => OrderingTerm.asc(row.id)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> _record(OutboxEntry entry, OutboxResult result) {
    final row = _db.update(_db.outboxEntries)..where((row) => row.id.equals(entry.id));
    return switch (result.outcome) {
      OutboxOutcome.sent => (_db.delete(_db.outboxEntries)..where((row) => row.id.equals(entry.id))).go(),
      OutboxOutcome.retryLater => row.write(OutboxEntriesCompanion(attempts: Value(entry.attempts + 1))),
      OutboxOutcome.rejected => row.write(
        OutboxEntriesCompanion(attempts: Value(entry.attempts + 1), rejected: const Value(true), lastError: Value(result.message)),
      ),
    };
  }

  /// Contagens do comércio logado (a fila de outra conta no aparelho não aparece).
  Future<void> refreshCounts() async {
    final owner = await _store.owner();
    final (pending, rejected) = owner == null ? (0, 0) : await _countsOf(owner.id);
    if (pending == _pendingCount && rejected == _rejectedCount) return;
    _pendingCount = pending;
    _rejectedCount = rejected;
    notifyListeners();
  }

  Future<(int, int)> _countsOf(String ownerId) async {
    final table = _db.outboxEntries;
    final pending = table.id.count(filter: table.rejected.equals(false));
    final rejected = table.id.count(filter: table.rejected.equals(true));
    final row =
        await (_db.selectOnly(table)
              ..addColumns([pending, rejected])
              ..where(table.ownerId.equals(ownerId)))
            .getSingle();
    return (row.read(pending) ?? 0, row.read(rejected) ?? 0);
  }

  /// Tudo o que o comércio logado tem na fila, da mais antiga para a mais nova. A fila só tem o que
  /// foi feito sem internet neste aparelho (um dia inteiro sem sinal dá algumas centenas): ler tudo
  /// custa ~11 ms com 1000 itens, então não pagina; a tela é que monta só os cartões visíveis.
  Future<List<PendingChange>> list() async {
    final owner = await _store.owner();
    if (owner == null) return const [];
    final query = _db.select(_db.outboxEntries)
      ..where((row) => row.ownerId.equals(owner.id))
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt), (row) => OrderingTerm.asc(row.sequence), (row) => OrderingTerm.asc(row.id)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        PendingChange(
          id: row.id,
          kind: row.kind,
          payload: jsonDecode(row.payload) as Map<String, dynamic>,
          createdAt: row.createdAt,
          rejected: row.rejected,
          reason: row.lastError,
        ),
    ];
  }

  /// Devolve uma recusada para a fila (ex.: o comerciante corrigiu o que faltava) e tenta enviar.
  /// Devolve se a fila esvaziou.
  Future<bool> retry(String id) async {
    await (_db.update(_db.outboxEntries)..where((row) => row.id.equals(id) & row.rejected.equals(true))).write(
      const OutboxEntriesCompanion(rejected: Value(false), lastError: Value(null)),
    );
    await refreshCounts();
    return flush();
  }

  /// Apaga uma recusada, depois que o comerciante confirmou. Só recusadas: uma pendente ainda vai subir,
  /// e apagá-la perderia uma venda ou um pagamento que o servidor aceitaria.
  Future<void> discard(String id) async {
    final deleted = await (_db.delete(_db.outboxEntries)..where((row) => row.id.equals(id) & row.rejected.equals(true))).go();
    await refreshCounts();
    if (deleted > 0) _discarded.add(null);
  }

  /// Saída da conta com alterações não enviadas, depois que o comerciante confirmou que aceita perdê-las.
  Future<void> discardOwnerEntries() async {
    final owner = await _store.owner();
    if (owner != null) await (_db.delete(_db.outboxEntries)..where((row) => row.ownerId.equals(owner.id))).go();
    await refreshCounts();
  }

  @override
  void dispose() {
    unawaited(_events.close());
    unawaited(_flushed.close());
    unawaited(_discarded.close());
    super.dispose();
  }
}
