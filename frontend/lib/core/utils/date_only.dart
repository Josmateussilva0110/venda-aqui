/// Datas sem hora (vencimento do fiado) trafegam como "AAAA-MM-DD" e viram meia-noite no fuso do aparelho.
abstract final class DateOnly {
  static DateTime today([DateTime? now]) {
    final moment = now ?? DateTime.now();
    return DateTime(moment.year, moment.month, moment.day);
  }

  /// Nulo quando o texto não é uma data.
  static DateTime? tryParse(String? value) {
    final parsed = value == null ? null : DateTime.tryParse(value);
    return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static String toApi(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Dias de calendário entre as datas; em UTC para o horário de verão não tirar uma hora do dia.
  static int daysBetween(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
}
