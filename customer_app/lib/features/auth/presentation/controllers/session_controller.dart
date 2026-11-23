import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../domain/auth_repository.dart';

enum SessionStatus { restoring, restoreFailed, signedIn, signedOut }

/// Estado global de sessão: o roteador escuta este controller para decidir a tela.
class SessionController extends ChangeNotifier {
  SessionController(this._repository);

  final AuthRepository _repository;

  SessionStatus _status = SessionStatus.restoring;
  bool _endedByServer = false;

  SessionStatus get status => _status;

  /// Verdadeiro uma única vez depois que o servidor encerrou a sessão (para avisar o usuário).
  bool consumeEndedByServer() {
    final value = _endedByServer;
    _endedByServer = false;
    return value;
  }

  Future<void> restore() async {
    _set(SessionStatus.restoring);
    try {
      _set(await _repository.restoreSession() ? SessionStatus.signedIn : SessionStatus.signedOut);
    } on AppFailure {
      _set(SessionStatus.restoreFailed);
    }
  }

  void signedIn() => _set(SessionStatus.signedIn);

  Future<void> logout() async {
    await _repository.logout();
    _set(SessionStatus.signedOut);
  }

  /// Chamado pelo interceptor quando a API recusa a sessão de vez (ex.: PIN redefinido em outro aparelho).
  void sessionEnded() {
    if (_status != SessionStatus.signedIn) return;
    _endedByServer = true;
    _set(SessionStatus.signedOut);
  }

  void _set(SessionStatus status) {
    _status = status;
    notifyListeners();
  }
}
