import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/notifications/reminder_notifier.dart';

// Aviso na hora errada (ou nenhum) faz o comerciante esquecer de cobrar
void main() {
  final morning = DateTime(2026, 11, 11, 8);
  final afternoon = DateTime(2026, 11, 11, 15);

  test('com pendentes, avisa hoje se a hora ainda não passou', () {
    final schedule = ReminderSchedule(dueCount: 2, nextOn: DateTime(2026, 11, 13), hour: 9);
    expect(schedule.nextAlertAfter(morning), DateTime(2026, 11, 11, 9));
  });

  test('hora de hoje já passou: avisa no próximo dia de lembrete', () {
    final schedule = ReminderSchedule(dueCount: 2, nextOn: DateTime(2026, 11, 13), hour: 9);
    expect(schedule.nextAlertAfter(afternoon), DateTime(2026, 11, 13, 9));
  });

  test('sem pendentes nem próximo dia, não agenda nada', () {
    expect(const ReminderSchedule(dueCount: 0, nextOn: null, hour: 9).nextAlertAfter(morning), isNull);
  });
}
