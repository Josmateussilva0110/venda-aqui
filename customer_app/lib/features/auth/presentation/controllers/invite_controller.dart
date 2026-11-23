import 'package:flutter/foundation.dart';

import '../../../../core/network/api_codes.dart';
import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../../domain/invite_info.dart';

/// O que o link pede: criar o primeiro PIN, o PIN atual (para juntar a loja) ou um PIN novo (esqueci).
enum InviteMode { createPin, currentPin, resetPin }

sealed class InviteState {
  const InviteState();
}

final class InviteLoading extends InviteState {
  const InviteLoading();
}

/// Vencido, já usado, ou a loja trocou o telefone do cadastro.
final class InviteInvalid extends InviteState {
  const InviteInvalid();
}

final class InviteLoadFailed extends InviteState {
  const InviteLoadFailed(this.failure);
  final AppFailure failure;
}

final class InviteReady extends InviteState {
  const InviteReady(this.info);
  final InviteInfo info;
}

sealed class InviteIssue {
  const InviteIssue();
}

final class InvitePinTooShort extends InviteIssue {
  const InvitePinTooShort();
}

final class InvitePinsDiffer extends InviteIssue {
  const InvitePinsDiffer();
}

final class InviteFailed extends InviteIssue {
  const InviteFailed(this.failure);
  final AppFailure failure;
}

class InviteController extends ChangeNotifier with DisposeAwareNotifier {
  InviteController(this._repository, {required this._token});

  final AuthRepository _repository;
  final String? _token;

  InviteState _state = const InviteLoading();
  InviteMode _mode = InviteMode.createPin;
  String _pin = '';
  String _confirmation = '';
  InviteIssue? _issue;
  bool _isSubmitting = false;

  InviteState get state => _state;
  InviteMode get mode => _mode;
  InviteIssue? get issue => _issue;
  bool get isSubmitting => _isSubmitting;
  bool get asksNewPin => _mode != InviteMode.currentPin;
  bool get canSubmit => AuthRules.isPinLengthValid(_pin) && (!asksNewPin || _confirmation.isNotEmpty);

  Future<void> load() async {
    final token = _token;
    if (token == null || token.isEmpty) return _setState(const InviteInvalid());
    _setState(const InviteLoading());
    try {
      final info = await _repository.inspectInvite(token);
      _mode = info.hasAccount ? InviteMode.currentPin : InviteMode.createPin;
      _setState(InviteReady(info));
    } on AppFailure catch (failure) {
      _setState(_isInviteInvalid(failure) ? const InviteInvalid() : InviteLoadFailed(failure));
    }
  }

  /// Só para conta existente: alterna entre informar o PIN atual e criar um novo.
  void toggleForgotPin() {
    if (_mode == InviteMode.createPin) return;
    _mode = _mode == InviteMode.currentPin ? InviteMode.resetPin : InviteMode.currentPin;
    _pin = '';
    _confirmation = '';
    _issue = null;
    notifyListeners();
  }

  void setPin(String text) {
    _pin = text;
    _issue = null;
    notifyListeners();
  }

  void setConfirmation(String text) {
    _confirmation = text;
    _issue = null;
    notifyListeners();
  }

  /// Verdadeiro quando o acesso foi liberado (a sessão já está salva).
  Future<bool> submit() async {
    final token = _token;
    if (_isSubmitting || token == null) return false;
    final localIssue = _localIssue();
    if (localIssue != null) {
      _issue = localIssue;
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    _issue = null;
    notifyListeners();
    try {
      await _repository.acceptInvite(token: token, currentPin: asksNewPin ? null : _pin, newPin: asksNewPin ? _pin : null);
      return true;
    } on AppFailure catch (failure) {
      _onSubmitFailure(failure);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  InviteIssue? _localIssue() {
    if (!AuthRules.isPinLengthValid(_pin)) return const InvitePinTooShort();
    if (asksNewPin && _pin != _confirmation) return const InvitePinsDiffer();
    return null;
  }

  void _onSubmitFailure(AppFailure failure) {
    if (_isInviteInvalid(failure)) {
      _state = const InviteInvalid();
      return;
    }
    // O acesso deixou de existir entre abrir o link e enviar: o certo agora é criar o PIN
    if (failure is RequestFailure && failure.code == ApiCodes.inviteNeedsNewPin) _mode = InviteMode.createPin;
    _pin = '';
    _confirmation = '';
    _issue = InviteFailed(failure);
  }

  static bool _isInviteInvalid(AppFailure failure) => failure is RequestFailure && failure.code == ApiCodes.inviteInvalid;

  void _setState(InviteState state) {
    _state = state;
    notifyListeners();
  }
}
