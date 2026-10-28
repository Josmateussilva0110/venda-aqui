import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../network/app_failure.dart';

/// Aviso rápido no estilo do toast do protótipo.
void showAppToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message, textAlign: TextAlign.center)));
}

/// Mensagem para o usuário a partir da falha. Detalhe técnico nunca chega à tela.
String failureMessage(AppLocalizations l10n, AppFailure failure) {
  return switch (failure) {
    NetworkFailure() => l10n.genericNetworkError,
    ServerFailure() => l10n.genericServerError,
    SessionExpiredFailure() => l10n.genericSessionExpired,
    RequestFailure(:final message) => message,
    ValidationFailure(:final firstMessage) => firstMessage ?? l10n.genericServerError,
  };
}
