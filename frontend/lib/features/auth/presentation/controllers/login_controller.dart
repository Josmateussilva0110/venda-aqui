import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/phone_format.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../../domain/merchant.dart';

sealed class LoginIssue {
  const LoginIssue();
}

final class LoginMissingFields extends LoginIssue {
  const LoginMissingFields();
}

final class LoginFailed extends LoginIssue {
  const LoginFailed(this.failure);
  final AppFailure failure;
}

class LoginController extends ChangeNotifier {
  LoginController(this._repository, {String initialPhone = ''}) : _phone = initialPhone;

  final AuthRepository _repository;

  String _phone;
  String _pin = '';
  LoginIssue? _issue;
  bool _isSubmitting = false;

  String get phone => _phone;
  String get pin => _pin;
  LoginIssue? get issue => _issue;
  bool get isSubmitting => _isSubmitting;
  bool get canSubmit => PhoneFormat.isComplete(_phone) && _pin.length >= AuthRules.pinMinLength;

  /// Recebe o texto com máscara; guarda só os dígitos.
  void setPhone(String text) {
    _phone = PhoneFormat.digitsOnly(text);
    _issue = null;
    notifyListeners();
  }

  void setPin(String text) {
    _pin = text;
    _issue = null;
    notifyListeners();
  }

  /// Devolve o comerciante quando o login dá certo.
  Future<Merchant?> submit() async {
    if (_isSubmitting) return null;
    if (!canSubmit) {
      _issue = const LoginMissingFields();
      notifyListeners();
      return null;
    }
    _isSubmitting = true;
    _issue = null;
    notifyListeners();
    try {
      return await _repository.login(phoneDigits: _phone, pin: _pin);
    } on AppFailure catch (failure) {
      _issue = LoginFailed(failure);
      _pin = '';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
