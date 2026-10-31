import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/session_controller.dart';

/// Enquanto a sessão guardada é restaurada (ou quando falhou por falta de rede).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = context.select<SessionController, SessionStatus>((session) => session.status);
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.primary,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.spacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandLogo(markSize: context.sizes.logoMedium, fontSize: 30, tone: BrandTone.onPrimary),
                  SizedBox(height: context.spacing.xxl),
                  if (status == SessionStatus.restoreFailed) ...[
                    Text(
                      l10n.genericNetworkError,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(color: colors.onPrimaryMuted),
                    ),
                    SizedBox(height: context.spacing.lg),
                    FilledButton(
                      onPressed: () => context.read<SessionController>().restore(),
                      style: FilledButton.styleFrom(backgroundColor: colors.surface, foregroundColor: colors.primary),
                      child: Text(l10n.retry),
                    ),
                  ] else
                    Semantics(
                      label: l10n.splashLoading,
                      child: CircularProgressIndicator(color: colors.onPrimary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
