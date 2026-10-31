import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../network/app_failure.dart';
import '../theme/theme_context.dart';

enum ToastTone { success, error }

/// Aviso rápido: pílula flutuante embaixo, acima da barra de navegação. É o único jeito de o app
/// mostrar mensagens (sucesso ou erro); as telas não exibem texto de erro solto.
void showAppToast(BuildContext context, String message, {ToastTone tone = ToastTone.success}) {
  ScaffoldMessenger.of(context).showAppToast(message, tone: tone);
}

/// Para mostrar o toast depois de um `await`, quando a tela que chamou pode já ter saído:
/// guarde `ScaffoldMessenger.of(context)` antes e chame isto depois.
extension AppToastMessenger on ScaffoldMessengerState {
  void showAppToast(String message, {ToastTone tone = ToastTone.success}) {
    this
      ..hideCurrentSnackBar()
      ..showSnackBar(_appToast(message, tone));
  }
}

SnackBar _appToast(String message, ToastTone tone) {
  // O SnackBar fica transparente e sem sombra: quem desenha é a pílula, do tamanho do texto
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    content: Center(
      child: _ToastPill(message: message, tone: tone),
    ),
  );
}

class _ToastPill extends StatelessWidget {
  const _ToastPill({required this.message, required this.tone});

  final String message;
  final ToastTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isError = tone == ToastTone.error;
    // Cor invertida em relação ao tema (escura no claro, clara no escuro), para destacar nos dois
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.chipActive,
          borderRadius: BorderRadius.circular(context.radius.pill),
          boxShadow: context.cardShadow,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(spacing.sm, spacing.sm, spacing.lg, spacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: isError ? colors.danger : colors.success, shape: BoxShape.circle),
                child: Padding(
                  padding: EdgeInsets.all(spacing.xs),
                  child: Icon(
                    isError ? Icons.priority_high_rounded : Icons.check_rounded,
                    color: colors.onPrimary,
                    size: context.sizes.iconSmall,
                  ),
                ),
              ),
              SizedBox(width: spacing.sm + 2),
              Flexible(
                child: Text(
                  message,
                  style: context.text.titleSmall?.copyWith(color: colors.onChipActive, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
