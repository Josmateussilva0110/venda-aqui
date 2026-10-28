import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/keypad_input.dart';
import '../../../../core/utils/phone_format.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../../domain/merchant.dart';

enum LoginField { phone, pin }

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
  LoginController(this._repository, {String initialPhone = ''})
    : _phone = initialPhone,
      _focus = initialPhone.isEmpty ? LoginField.phone : LoginField.pin;

  final AuthRepository _repository;

  String _phone;
  String _pin = '';
  LoginField _focus;
  LoginIssue? _issue;
  bool _isSubmitting = false;

  String get phone => _phone;
  String get pin => _pin;
  LoginField get focus => _focus;
  LoginIssue? get issue => _issue;
  bool get isSubmitting => _isSubmitting;
  bool get canSubmit => PhoneFormat.isComplete(_phone) && _pin.length >= AuthRules.pinMinLength;

  void focusOn(LoginField field) {
    _focus = field;
    notifyListeners();
  }

  void onKey(KeypadKey key) {
    _issue = null;
    if (_focus == LoginField.phone) {
      _phone = KeypadInput.applyDigits(_phone, key, maxLength: PhoneFormat.maxDigits);
      // Celular completo: pula sozinho para o PIN, como no protótipo
      if (_phone.length == PhoneFormat.maxDigits && key is DigitKey) _focus = LoginField.pin;
    } else if (key is BackspaceKey && _pin.isEmpty) {
      _focus = LoginField.phone;
    } else {
      _pin = KeypadInput.applyDigits(_pin, key, maxLength: AuthRules.pinMaxLength);
    }
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
      _focus = LoginField.pin;
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
