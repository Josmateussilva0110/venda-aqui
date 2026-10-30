import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../domain/auth_repository.dart';
import '../../domain/merchant.dart';

enum SessionStatus { restoring, restoreFailed, signedIn, signedOut }

/// Estado global de sessão: o roteador escuta este controller para decidir a tela.
class SessionController extends ChangeNotifier {
  SessionController(this._repository);

  final AuthRepository _repository;

  SessionStatus _status = SessionStatus.restoring;
  Merchant? _merchant;
  bool _endedByServer = false;

  SessionStatus get status => _status;
  Merchant? get merchant => _merchant;

  /// Verdadeiro uma única vez depois que o servidor encerrou a sessão (para avisar o usuário).
  bool consumeEndedByServer() {
    final value = _endedByServer;
    _endedByServer = false;
    return value;
  }

  Future<void> restore() async {
    _set(SessionStatus.restoring);
    try {
      final merchant = await _repository.restoreSession();
      _merchant = merchant;
      _set(merchant == null ? SessionStatus.signedOut : SessionStatus.signedIn);
    } on AppFailure {
      _set(SessionStatus.restoreFailed);
    }
  }

  void signedIn(Merchant merchant) {
    _merchant = merchant;
    _set(SessionStatus.signedIn);
  }

  Future<void> logout() async {
    await _repository.logout();
    _merchant = null;
    _set(SessionStatus.signedOut);
  }

  /// Chamado pelo interceptor quando a API recusa a sessão de vez.
  void sessionEnded() {
    if (_status != SessionStatus.signedIn) return;
    _merchant = null;
    _endedByServer = true;
    _set(SessionStatus.signedOut);
  }

  void _set(SessionStatus status) {
    _status = status;
    notifyListeners();
  }
}
