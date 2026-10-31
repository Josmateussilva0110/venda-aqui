import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/phone_format.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_rules.dart';
import '../../domain/merchant.dart';

enum RegisterStep { business, createPin, repeatPin }

/// Problemas mostrados ao usuário; os textos ficam na tela (localização).
enum RegisterIssue { nameRequired, phoneInvalid, phoneTaken, pinTooShort, pinMismatch }

class RegisterController extends ChangeNotifier {
  RegisterController(this._repository);

  final AuthRepository _repository;

  RegisterStep _step = RegisterStep.business;
  String _name = '';
  String _phone = '';
  String _pin = '';
  String _pinRepeat = '';
  RegisterIssue? _issue;
  AppFailure? _failure;
  bool _isBusy = false;

  RegisterStep get step => _step;
  String get phone => _phone;
  String get pin => _pin;
  String get pinRepeat => _pinRepeat;
  RegisterIssue? get issue => _issue;
  AppFailure? get failure => _failure;
  bool get isBusy => _isBusy;
  bool get businessComplete => _name.trim().isNotEmpty && PhoneFormat.isComplete(_phone);
  bool get pinLongEnough => _pin.length >= AuthRules.pinMinLength;

  void setName(String value) {
    _name = value;
    _clearIssues();
    notifyListeners();
  }

  void setPhone(String formatted) {
    _phone = PhoneFormat.digitsOnly(formatted);
    _clearIssues();
    notifyListeners();
  }

  Future<void> submitBusiness() async {
    if (_name.trim().isEmpty) return _report(RegisterIssue.nameRequired);
    if (!PhoneFormat.isComplete(_phone)) return _report(RegisterIssue.phoneInvalid);

    await _run(() async {
      final available = await _repository.isPhoneAvailable(_phone);
      if (available) {
        _step = RegisterStep.createPin;
      } else {
        _issue = RegisterIssue.phoneTaken;
      }
    });
  }

  void submitCreatedPin() {
    if (!pinLongEnough) return _report(RegisterIssue.pinTooShort);
    _step = RegisterStep.repeatPin;
    _pinRepeat = '';
    _clearIssues();
    notifyListeners();
  }

  void setPin(String digits) {
    _pin = digits;
    _clearIssues();
    notifyListeners();
  }

  /// Ao completar a repetição, confere e cria a conta. Devolve o comerciante quando dá certo.
  Future<Merchant?> setPinRepeat(String digits) async {
    if (_isBusy) return null;
    _pinRepeat = digits;
    _clearIssues();
    notifyListeners();
    if (_pinRepeat.length < _pin.length) return null;
    if (_pinRepeat != _pin) {
      _pinRepeat = '';
      _report(RegisterIssue.pinMismatch);
      return null;
    }
    return _createAccount();
  }

  void goBack() {
    _step = switch (_step) {
      RegisterStep.business || RegisterStep.createPin => RegisterStep.business,
      RegisterStep.repeatPin => RegisterStep.createPin,
    };
    _pinRepeat = '';
    if (_step == RegisterStep.business) _pin = '';
    _clearIssues();
    notifyListeners();
  }

  Future<Merchant?> _createAccount() async {
    Merchant? merchant;
    await _run(() async {
      merchant = await _repository.register(name: _name.trim(), phoneDigits: _phone, pin: _pin);
    });
    // PIN recusado pelo servidor (ex.: "1234"): volta para escolher outro
    final failure = _failure;
    if (failure != null) _pinRepeat = '';
    if (failure is ValidationFailure && failure['pin'] != null) {
      _step = RegisterStep.createPin;
      _pin = '';
      _pinRepeat = '';
      notifyListeners();
    } else if (failure is ValidationFailure || failure is RequestFailure) {
      _step = RegisterStep.business;
      notifyListeners();
    }
    return merchant;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    _isBusy = true;
    _failure = null;
    notifyListeners();
    try {
      await action();
    } on AppFailure catch (failure) {
      _failure = failure;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void _report(RegisterIssue issue) {
    _issue = issue;
    _failure = null;
    notifyListeners();
  }

  void _clearIssues() {
    _issue = null;
    _failure = null;
  }
}
