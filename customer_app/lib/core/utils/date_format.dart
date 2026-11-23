import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Datas na tela, no idioma do app.
abstract final class AppDateFormat {
  /// "05/12/2026"
  static String day(BuildContext context, DateTime date) => dayIn(_locale(context), date);

  /// "05/12/2026 14:30"
  static String moment(BuildContext context, DateTime date) => momentIn(_locale(context), date);

  /// Igual a [moment], para quem formata fora de um widget (ex.: PDF) com o `localeName` do l10n.
  static String momentIn(String locale, DateTime date) => DateFormat('dd/MM/yyyy HH:mm', locale).format(date);

  static String dayIn(String locale, DateTime date) => DateFormat('dd/MM/yyyy', locale).format(date);

  /// "2026-12-05", para nome de arquivo (ordena por data).
  static String fileDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static String _locale(BuildContext context) => Localizations.localeOf(context).toString();
}
