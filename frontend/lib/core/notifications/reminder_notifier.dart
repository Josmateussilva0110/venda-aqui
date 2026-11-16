import 'package:flutter/foundation.dart';

import '../network/json_reader.dart';
import '../utils/date_only.dart';

/// Quando avisar o comerciante dos lembretes do fiado, como o servidor calcula no resumo.
@immutable
class ReminderSchedule {
  const ReminderSchedule({required this.dueCount, required this.nextOn, required this.hour});

  /// Lembretes pendentes agora.
  final int dueCount;

  /// Próximo dia em que um lembrete novo fica pendente; nulo se não haverá outro.
  final DateTime? nextOn;

  /// Hora do aviso (0 a 23) no fuso do aparelho.
  final int hour;

  /// Campo `reminders` do resumo do fiado (`GET /customers`); nulo com os lembretes desligados.
  /// Fica aqui porque o início e a lista de devedores leem o mesmo resumo.
  static ReminderSchedule? fromSummaryJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return ReminderSchedule(
      dueCount: json.requireInt('dueCount'),
      nextOn: DateOnly.tryParse(json.optionalString('nextOn')),
      hour: json.requireInt('hour'),
    );
  }

  /// Hoje na hora configurada, se há pendentes e a hora ainda não passou; senão o próximo dia de lembrete.
  /// Nulo quando não há o que avisar.
  DateTime? nextAlertAfter(DateTime now) {
    final todayAlert = DateTime(now.year, now.month, now.day, hour);
    if (dueCount > 0 && todayAlert.isAfter(now)) return todayAlert;
    final next = nextOn;
    if (next == null) return null;
    final nextAlert = DateTime(next.year, next.month, next.day, hour);
    return nextAlert.isAfter(now) ? nextAlert : null;
  }
}

/// Aviso no aparelho para o comerciante abrir os lembretes do dia. O envio ao cliente continua
/// sendo dele, pelo WhatsApp; o aviso só lembra que há mensagens para mandar.
abstract interface class ReminderNotifier {
  /// Troca o aviso agendado pelo de [schedule]; nulo (lembretes desligados) só cancela.
  /// Não pede permissão. Nunca lança: aviso que falha não pode atrapalhar a tela que chamou.
  Future<void> sync(ReminderSchedule? schedule);

  /// Toques no aviso com o app já aberto (em primeiro plano ou em segundo plano).
  Stream<void> get alertTaps;

  /// Se o app foi aberto (estava fechado) por um toque no aviso. Responde `true` só uma vez,
  /// para a lista de lembretes não abrir de novo a cada vez que o início é montado.
  Future<bool> consumeLaunchTap();

  /// Pede ao sistema permissão para avisar. Só em resposta a uma ação do comerciante com os lembretes
  /// (salvar a configuração, abrir a lista), para o pedido não aparecer do nada a cada venda.
  Future<void> requestPermission();
}
