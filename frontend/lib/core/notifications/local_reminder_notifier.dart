import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import 'reminder_notifier.dart';

/// Aviso local (sem servidor de push): um único aviso agendado, trocado a cada [sync].
class LocalReminderNotifier implements ReminderNotifier {
  LocalReminderNotifier([FlutterLocalNotificationsPlugin? plugin]) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initializing;

  final _taps = StreamController<void>.broadcast();
  bool _launchTapConsumed = false;

  // O resumo do fiado recarrega a cada venda: sem mudança no horário, não mexe no aviso
  DateTime? _scheduledFor;
  bool _synced = false;

  static const _notificationId = 1;
  static const _channelId = 'credit_reminders';
  static const _icon = '@mipmap/ic_launcher';

  // O app só tem português; o aviso é montado fora de uma tela, sem contexto para ler o idioma
  static final AppLocalizations _l10n = lookupAppLocalizations(const Locale('pt'));

  @override
  Future<void> sync(ReminderSchedule? schedule) async {
    try {
      final when = schedule?.nextAlertAfter(DateTime.now());
      if (_synced && when == _scheduledFor) return;
      await _ensureInitialized();
      await _plugin.cancel(id: _notificationId);
      _scheduledFor = null;
      _synced = true;
      if (when == null) return;

      // Sem permissão o sistema só não mostra o aviso; agendar mesmo assim cobre quem permitir depois
      await _plugin.zonedSchedule(
        id: _notificationId,
        title: _l10n.reminderAlertTitle,
        body: _l10n.reminderAlertBody,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(_channelId, _l10n.reminderChannelName, channelDescription: _l10n.reminderChannelDescription),
        ),
        // Sem alarme exato: alguns minutos de atraso não importam e dispensam permissão especial
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      _scheduledFor = when;
    } catch (error) {
      // Aviso é conveniência: se o sistema recusar, os lembretes continuam no app
      if (kDebugMode) debugPrint('[LocalReminderNotifier] ${error.runtimeType}');
    }
  }

  @override
  Stream<void> get alertTaps {
    // Escutar os toques exige o plugin inicializado; quem escuta é o início, que abre com o app
    unawaited(_ensureInitialized());
    return _taps.stream;
  }

  @override
  Future<bool> consumeLaunchTap() async {
    if (_launchTapConsumed) return false;
    _launchTapConsumed = true;
    try {
      await _ensureInitialized();
      final launch = await _plugin.getNotificationAppLaunchDetails();
      return (launch?.didNotificationLaunchApp ?? false) && launch?.notificationResponse?.id == _notificationId;
    } catch (error) {
      if (kDebugMode) debugPrint('[LocalReminderNotifier] ${error.runtimeType}');
      return false;
    }
  }

  @override
  Future<void> requestPermission() async {
    try {
      await _ensureInitialized();
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    } catch (error) {
      if (kDebugMode) debugPrint('[LocalReminderNotifier] ${error.runtimeType}');
    }
  }

  Future<void> _ensureInitialized() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings(_icon)),
      onDidReceiveNotificationResponse: (response) {
        if (response.id == _notificationId) _taps.add(null);
      },
    );
  }
}
