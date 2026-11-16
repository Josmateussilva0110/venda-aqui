import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/notifications/reminder_notifier.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';

enum CreditSettingsStatus { loading, ready, failure }

/// Prazo do fiado e agenda dos lembretes. As mudanças ficam no rascunho até salvar.
class CreditSettingsController extends ChangeNotifier with DisposeAwareNotifier {
  CreditSettingsController(this._repository, this._notifier);

  final CustomersRepository _repository;
  final ReminderNotifier _notifier;

  CreditSettingsStatus _status = CreditSettingsStatus.loading;
  CreditSettings? _settings;
  AppFailure? _failure;
  bool _isSaving = false;

  CreditSettingsStatus get status => _status;
  CreditSettings? get settings => _settings;
  AppFailure? get failure => _failure;
  bool get isSaving => _isSaving;

  Future<void> load() async {
    _status = CreditSettingsStatus.loading;
    _failure = null;
    notifyListeners();
    try {
      _settings = await _repository.creditSettings();
      _status = CreditSettingsStatus.ready;
    } on AppFailure catch (failure) {
      _failure = failure;
      _status = CreditSettingsStatus.failure;
    }
    notifyListeners();
  }

  void update(CreditSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  /// Salva e reagenda o aviso com a agenda nova. Lança [AppFailure] se o servidor recusar.
  Future<void> save() async {
    final settings = _settings;
    if (_isSaving || settings == null) return;
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.saveCreditSettings(settings);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    if (settings.remindersEnabled) await _notifier.requestPermission();
    await _syncReminderAlert();
  }

  // Quem e quando lembrar é o servidor que calcula: busca o resumo de novo com a configuração salva
  Future<void> _syncReminderAlert() async {
    try {
      final summary = await _repository.summary();
      await _notifier.sync(summary.reminders);
    } on AppFailure {
      // A configuração já foi salva; o aviso se acerta na próxima vez que o início carregar o fiado
    }
  }
}
