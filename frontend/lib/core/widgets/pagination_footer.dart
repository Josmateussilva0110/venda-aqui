import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../network/app_failure.dart';
import 'app_feedback.dart';
import 'state_views.dart';

/// Rodapé de lista paginada pelo servidor: carregando mais, erro com nova tentativa ou nada no fim.
class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    super.key,
    required this.hasMore,
    required this.isLoadingMore,
    required this.failure,
    required this.onLoadMore,
    required this.onRetry,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final AppFailure? failure;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = this.failure;
    if (failure != null) return ErrorView(message: failureMessage(AppLocalizations.of(context), failure), onRetry: onRetry);
    if (hasMore && !isLoadingMore) {
      // Se a primeira página não encheu a tela, não haverá rolagem para pedir a próxima
      WidgetsBinding.instance.addPostFrameCallback((_) => onLoadMore());
    }
    return hasMore ? const LoadingView() : const SizedBox.shrink();
  }
}
