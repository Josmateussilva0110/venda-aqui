import 'package:go_router/go_router.dart';

import '../core/routing/app_routes.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/auth/presentation/pages/invite_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/paste_invite_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/stores/domain/store.dart';
import '../features/stores/presentation/pages/statement_page.dart';
import '../features/stores/presentation/pages/stores_page.dart';

/// Rotas do app. A sessão decide para onde ir: sem login, só o acesso e o link da loja.
GoRouter buildRouter(SessionController session, {String initialLocation = AppRoutes.splash}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: session,
    redirect: (_, state) => redirectFor(session.status, state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.pasteInvite, builder: (_, _) => const PasteInvitePage()),
      GoRoute(
        path: AppRoutes.invite,
        builder: (_, state) => InvitePage(token: state.uri.queryParameters[AppRoutes.inviteTokenParam]),
      ),
      GoRoute(path: AppRoutes.stores, builder: (_, _) => const StoresPage()),
      GoRoute(
        path: '${AppRoutes.stores}/:id',
        // A loja vem da lista; sem ela (rota aberta de outro jeito) volta para a lista
        redirect: (_, state) => state.extra is Store ? null : AppRoutes.stores,
        builder: (_, state) => StatementPage(store: state.extra! as Store),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => SettingsPage(onLogout: session.logout),
      ),
    ],
  );
}

/// As telas do link abrem em qualquer estado: logado, o link junta mais uma loja ao acesso.
String? redirectFor(SessionStatus status, String location) {
  if (AppRoutes.inviteRoutes.contains(location)) return null;
  final isPublic = AppRoutes.publicRoutes.contains(location);
  return switch (status) {
    SessionStatus.restoring || SessionStatus.restoreFailed => location == AppRoutes.splash ? null : AppRoutes.splash,
    SessionStatus.signedOut => isPublic ? null : AppRoutes.login,
    SessionStatus.signedIn => location == AppRoutes.login || location == AppRoutes.splash ? AppRoutes.stores : null,
  };
}
