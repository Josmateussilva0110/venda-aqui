import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/theme_context.dart';

/// Texto centralizado para listas vazias.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.huge),
      child: Text(message, textAlign: TextAlign.center, style: context.text.bodyMedium),
    );
  }
}

/// Erro com botão de tentar de novo.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.xxxl, horizontal: context.spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: context.text.bodyMedium),
          SizedBox(height: context.spacing.md),
          OutlinedButton(onPressed: onRetry, child: Text(AppLocalizations.of(context).retry)),
        ],
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.spacing.xxxl),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
