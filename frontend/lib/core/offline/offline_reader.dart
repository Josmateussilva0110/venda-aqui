import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/app_failure.dart';
import '../network/cancel_signal.dart';
import 'offline_status.dart';
import 'offline_store.dart';

/// Leitura com servidor primeiro e cópia local quando não há internet.
class OfflineReader {
  OfflineReader(this._store, this._status, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final OfflineStore _store;
  final OfflineStatus _status;
  final DateTime Function() _clock;

  /// Depois de uma falha de rede, as leituras vão direto à cópia por este tempo. Com sinal fraco
  /// cada tentativa espera o timeout inteiro; sem isso, cada rolagem e cada busca travariam de novo.
  static const retryAfter = Duration(seconds: 30);

  DateTime? _failedAt;

  OfflineStore get store => _store;

  /// Uma requisição acabou de falhar por falta de internet: quem grava pode ir direto para a fila,
  /// sem esperar o timeout de novo (no balcão, com o cliente esperando).
  bool get recentlyOffline {
    final failedAt = _failedAt;
    return failedAt != null && _clock().difference(failedAt) < retryAfter;
  }

  /// Gravações também contam: uma venda que não alcançou o servidor vale para as leituras seguintes.
  void noteNetworkFailure() => _failedAt = _clock();

  /// [remote] é a consulta normal. [save] guarda o resultado na cópia local, sem atrasar a tela.
  /// [local] responde sem internet; devolver nulo (ex.: item que não está na cópia) mantém a falha de rede.
  Future<T> read<T>({
    required Future<T> Function() remote,
    required Future<T?> Function(OfflineStore store) local,
    Future<void> Function(OfflineStore store, T value)? save,
    CancelSignal? cancel,
  }) async {
    if (recentlyOffline) {
      final value = await _fromCopy(local);
      if (value != null) return value;
    }

    try {
      final value = await remote();
      _failedAt = null;
      _status.markOnline();
      if (save != null) unawaited(_saveQuietly(() => save(_store, value)));
      return value;
    } on NetworkFailure {
      // Busca cancelada por outra também chega como falha de rede: não é falta de internet
      if (cancel?.isCancelled ?? false) rethrow;
      _failedAt = _clock();
      final value = await _fromCopy(local);
      if (value == null) rethrow;
      return value;
    }
  }

  /// Nulo quando não há cópia completa (nunca sincronizou) ou o item não está nela.
  Future<T?> _fromCopy<T>(Future<T?> Function(OfflineStore store) local) async {
    // Sem nenhuma sincronização completa a cópia pode estar pela metade: melhor avisar que falta internet
    final savedAt = await _store.lastSyncedAt();
    if (savedAt == null) return null;
    final value = await local(_store);
    if (value != null) _status.markOffline(savedAt);
    return value;
  }

  // Falhar ao guardar a cópia não pode estragar a resposta que já chegou do servidor
  Future<void> _saveQuietly(Future<void> Function() save) async {
    try {
      await save();
    } catch (error) {
      if (kDebugMode) debugPrint('[OfflineReader] cópia local não atualizada: ${error.runtimeType}');
    }
  }
}
