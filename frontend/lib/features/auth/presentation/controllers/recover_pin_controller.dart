import 'package:flutter/foundation.dart';

import '../../../../core/network/api_codes.dart';
import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/keypad_input.dart';
import '../../../../core/utils/phone_format.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../../domain/merchant.dart';

enum RecoverPhase { phone, code, newPin }

enum RecoverIssue { phoneInvalid, pinTooShort }

class RecoverPinController extends ChangeNotifier {
  RecoverPinController(this._repository, {String initialPhone = ''}) : _phone = initialPhone;

  final AuthRepository _repository;

  RecoverPhase _phase = RecoverPhase.phone;
  String _phone;
  String _code = '';
  String _pin = '';
  RecoverIssue? _issue;
  AppFailure? _failure;
  bool _isBusy = false;

  RecoverPhase get phase => _phase;
  String get phone => _phone;
  String get code => _code;
  String get pin => _pin;
  RecoverIssue? get issue => _issue;
  AppFailure? get failure => _failure;
  bool get isBusy => _isBusy;
  int get stepNumber => _phase.index + 1;
  bool get canContinue => switch (_phase) {
    RecoverPhase.phone => PhoneFormat.isComplete(_phone),
    RecoverPhase.code => _code.length == AuthRules.recoveryCodeLength,
    RecoverPhase.newPin => _pin.length >= AuthRules.pinMinLength,
  };

  void onKey(KeypadKey key) {
    _issue = null;
    _failure = null;
    switch (_phase) {
      case RecoverPhase.phone:
        _phone = KeypadInput.applyDigits(_phone, key, maxLength: PhoneFormat.maxDigits);
      case RecoverPhase.code:
        _code = KeypadInput.applyDigits(_code, key, maxLength: AuthRules.recoveryCodeLength);
        // O código só é conferido junto com o novo PIN, numa chamada só
        if (_code.length == AuthRules.recoveryCodeLength) {
          _phase = RecoverPhase.newPin;
          _pin = '';
        }
      case RecoverPhase.newPin:
        _pin = KeypadInput.applyDigits(_pin, key, maxLength: AuthRules.pinMaxLength);
    }
    notifyListeners();
  }

  /// Envia o código; devolve verdadeiro quando o pedido foi aceito.
  Future<bool> requestCode() async {
    if (!PhoneFormat.isComplete(_phone)) {
      _issue = RecoverIssue.phoneInvalid;
      notifyListeners();
      return false;
    }
    final sent = await _run(() => _repository.requestPinRecovery(_phone));
    if (sent) {
      _phase = RecoverPhase.code;
      _code = '';
      notifyListeners();
    }
    return sent;
  }

  Future<Merchant?> confirm() async {
    if (_pin.length < AuthRules.pinMinLength) {
      _issue = RecoverIssue.pinTooShort;
      notifyListeners();
      return null;
    }
    Merchant? merchant;
    await _run(() async {
      merchant = await _repository.confirmPinRecovery(phoneDigits: _phone, code: _code, pin: _pin);
    });
    final failure = _failure;
    final codeRejected = failure is RequestFailure && failure.code == ApiCodes.recoveryCodeInvalid;
    if (codeRejected || (failure is ValidationFailure && failure['code'] != null)) {
      _phase = RecoverPhase.code;
      _code = '';
      notifyListeners();
    }
    return merchant;
  }

  void goBack() {
    _phase = switch (_phase) {
      RecoverPhase.phone || RecoverPhase.code => RecoverPhase.phone,
      RecoverPhase.newPin => RecoverPhase.code,
    };
    _code = '';
    _pin = '';
    _issue = null;
    _failure = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_isBusy) return false;
    _isBusy = true;
    _failure = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AppFailure catch (failure) {
      _failure = failure;
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
