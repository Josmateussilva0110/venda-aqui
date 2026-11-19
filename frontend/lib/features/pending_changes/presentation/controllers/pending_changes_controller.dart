import 'package:flutter/foundation.dart';

import '../../../../core/offline/outbox.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';

/// Estado da tela de pendências. Recarrega sozinha quando a fila muda (algo subiu, foi recusado,
/// reenviado ou descartado), inclusive por um envio que começou fora da tela.
class PendingChangesController extends ChangeNotifier with DisposeAwareNotifier {
  PendingChangesController(this._outbox) {
    _outbox.addListener(_reload);
  }

  final Outbox _outbox;

  List<PendingChange> _pending = const [];
  List<PendingChange> _rejected = const [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _busyId;

  /// Esperando internet, na ordem em que vão subir.
  List<PendingChange> get pending => _pending;

  /// Recusadas pelo servidor, esperando o comerciante decidir.
  List<PendingChange> get rejected => _rejected;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;

  /// Alteração com reenvio ou descarte em andamento (desabilita os botões dela).
  String? get busyId => _busyId;
  bool get isEmpty => _pending.isEmpty && _rejected.isEmpty;

  Future<void> load() async {
    final changes = await _outbox.list();
    _pending = changes.where((change) => !change.rejected).toList(growable: false);
    _rejected = changes.where((change) => change.rejected).toList(growable: false);
    _isLoading = false;
    notifyListeners();
  }

  void _reload() {
    if (!isDisposed) load();
  }

  /// Tenta enviar agora. Devolve se a fila esvaziou (falso: ainda sem internet).
  Future<bool> sendNow() async {
    if (_isSending) return false;
    _isSending = true;
    notifyListeners();
    try {
      return await _outbox.flush();
    } finally {
      // A lista se recarrega pelo aviso do Outbox quando algo muda; aqui só sai o "enviando"
      _isSending = false;
      notifyListeners();
    }
  }

  /// Devolve uma recusada para a fila e tenta enviar. Devolve se a fila esvaziou.
  Future<bool> retry(String id) => _whileBusy(id, () => _outbox.retry(id));

  Future<void> discard(String id) => _whileBusy(id, () => _outbox.discard(id));

  Future<T> _whileBusy<T>(String id, Future<T> Function() action) async {
    _busyId = id;
    notifyListeners();
    try {
      return await action();
    } finally {
      _busyId = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _outbox.removeListener(_reload);
    super.dispose();
  }
}
