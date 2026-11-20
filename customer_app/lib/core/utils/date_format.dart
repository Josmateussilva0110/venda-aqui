import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Datas na tela, no idioma do app.
abstract final class AppDateFormat {
  /// "05/12/2026"
  static String day(BuildContext context, DateTime date) => DateFormat('dd/MM/yyyy', _locale(context)).format(date);

  /// "05/12/2026 14:30"
  static String moment(BuildContext context, DateTime date) => DateFormat('dd/MM/yyyy HH:mm', _locale(context)).format(date);

  static String _locale(BuildContext context) => Localizations.localeOf(context).toString();
}
