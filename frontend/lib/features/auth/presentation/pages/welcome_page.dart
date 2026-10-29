import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../l10n/app_localizations.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.colors.primary,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWideLandscape = constraints.maxWidth > constraints.maxHeight && constraints.maxWidth >= AppBreakpoints.medium;
            if (isWideLandscape) {
              return const Row(
                children: [
                  Expanded(
                    child: SafeArea(
                      right: false,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [_WelcomeIntro(), _WelcomeActions()]),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _WelcomeImage()),
                ],
              );
            }
            // Em telas baixas tudo rola; em telas altas a foto ocupa o espaço que sobra
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SafeArea(bottom: false, child: _WelcomeIntro()),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: context.sizes.welcomeImageMinHeight),
                          child: const _WelcomeImage(),
                        ),
                      ),
                      const _WelcomeActions(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeIntro extends StatelessWidget {
  const _WelcomeIntro();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.xxl + 4, spacing.huge, spacing.xxl + 4, spacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
        child: Column(
          children: [
            BrandLogo(markSize: context.sizes.logoSmall + 4, fontSize: 24, tone: BrandTone.onPrimary),
            SizedBox(height: spacing.md),
            Semantics(
              header: true,
              child: Text(
                l10n.welcomeHeadline,
                textAlign: TextAlign.center,
                style: context.text.displayMedium?.copyWith(color: colors.onPrimary),
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              l10n.welcomeSubtitle,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: colors.onPrimaryMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ilustração da feirante (fonte editável em `design/welcome_merchant.svg`).
/// Se o arquivo não estiver em assets, mostra a folha da marca no lugar.
class _WelcomeImage extends StatelessWidget {
  const _WelcomeImage();

  static const _assetPath = 'assets/images/welcome_merchant.jpg';
  static const _fadeHeightFactor = 0.25;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _assetPath,
          fit: BoxFit.cover,
          semanticLabel: l10n.welcomeImageLabel,
          errorBuilder: (context, _, _) => ColoredBox(
            color: colors.primary,
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.4,
                child: AspectRatio(
                  aspectRatio: 1,
                  // FittedBox em vez de LayoutBuilder: esta árvore participa do cálculo de altura intrínseca
                  child: FittedBox(
                    child: Opacity(
                      opacity: 0.35,
                      child: LeafMark(
                        size: context.sizes.photoBoxHeight,
                        leftLeaf: colors.onPrimary,
                        rightLeaf: colors.primaryTint,
                        dot: colors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Degradê que funde a foto com o verde do topo
        Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: _fadeHeightFactor,
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.primary, colors.primary.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final colors = context.colors;
    return ColoredBox(
      color: colors.primaryDark,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: spacing.xxl),
        child: Padding(
          padding: EdgeInsets.fromLTRB(spacing.xxl + 4, spacing.xl, spacing.xxl + 4, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    label: l10n.welcomeStart,
                    variant: AppButtonVariant.light,
                    shape: AppButtonShape.rounded,
                    onPressed: () => context.push(AppRoutes.register),
                  ),
                  SizedBox(height: spacing.sm),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.login),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.onPrimary,
                      minimumSize: Size.fromHeight(context.sizes.minTouchTarget),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: l10n.welcomeHaveAccount,
                        children: [
                          TextSpan(
                            text: l10n.welcomeSignIn,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      style: context.text.titleSmall?.copyWith(color: colors.onPrimary, fontWeight: FontWeight.w600),
                    ),
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
