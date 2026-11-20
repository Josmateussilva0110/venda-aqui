import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../controllers/invite_controller.dart';
import '../widgets/auth_page_frame.dart';
import '../widgets/invite_form.dart';
import '../widgets/invite_invalid_view.dart';

/// Aberta pelo link que a loja mandou no WhatsApp: cria o acesso ou junta a loja ao acesso existente.
class InvitePage extends StatelessWidget {
  const InvitePage({super.key, required this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InviteController(context.read<AuthRepository>(), token: token)..load(),
      child: const AuthPageFrame(child: _InviteView()),
    );
  }
}

class _InviteView extends StatelessWidget {
  const _InviteView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.select<InviteController, InviteState>((controller) => controller.state);
    return switch (state) {
      InviteLoading() => const Center(child: LoadingView()),
      InviteInvalid() => InviteInvalidView(onGoToLogin: () => context.go(AppRoutes.login)),
      InviteLoadFailed(:final failure) => Center(
        child: ErrorView(message: failureMessage(l10n, failure), onRetry: context.read<InviteController>().load),
      ),
      InviteReady(:final info) => InviteForm(info: info),
    };
  }
}
