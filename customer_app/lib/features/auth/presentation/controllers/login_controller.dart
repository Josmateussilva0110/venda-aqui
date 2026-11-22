import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/cpf_format.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../../../core/utils/phone_format.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../../domain/login_method.dart';

sealed class LoginIssue {
  const LoginIssue();
}

final class LoginMissingFields extends LoginIssue {
  const LoginMissingFields();
}

final class LoginInvalidCpf extends LoginIssue {
  const LoginInvalidCpf();
}

final class LoginFailed extends LoginIssue {
  const LoginFailed(this.failure);
  final AppFailure failure;
}

class LoginController extends ChangeNotifier with DisposeAwareNotifier {
  LoginController(this._repository);

  final AuthRepository _repository;

  LoginMethod _method = LoginMethod.phone;
  String _identifier = '';
  String _pin = '';
  LoginIssue? _issue;
  bool _isSubmitting = false;

  LoginMethod get method => _method;
  LoginIssue? get issue => _issue;
  bool get isSubmitting => _isSubmitting;

  bool get _identifierComplete => switch (_method) {
    LoginMethod.phone => PhoneFormat.isComplete(_identifier),
    LoginMethod.cpf => _identifier.length == CpfFormat.digitsLength,
  };

  bool get canSubmit => _identifierComplete && AuthRules.isPinLengthValid(_pin);

  /// Trocar de telefone para CPF apaga o que foi digitado: os dois têm máscaras diferentes.
  void setMethod(LoginMethod method) {
    if (method == _method) return;
    _method = method;
    _identifier = '';
    _issue = null;
    notifyListeners();
  }

  /// Recebe o texto com máscara; guarda só os dígitos.
  void setIdentifier(String text) {
    _identifier = text.replaceAll(RegExp(r'\D'), '');
    _issue = null;
    notifyListeners();
  }

  void setPin(String text) {
    _pin = text;
    _issue = null;
    notifyListeners();
  }

  /// Verdadeiro quando entrou.
  Future<bool> submit() async {
    if (_isSubmitting) return false;
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
      await _repository.login(method: _method, identifierDigits: _identifier, pin: _pin);
      return true;
    } on AppFailure catch (failure) {
      _issue = LoginFailed(failure);
      _pin = '';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  LoginIssue? _localIssue() {
    if (!canSubmit) return const LoginMissingFields();
    if (_method == LoginMethod.cpf && !CpfFormat.isValid(_identifier)) return const LoginInvalidCpf();
    return null;
  }
}
