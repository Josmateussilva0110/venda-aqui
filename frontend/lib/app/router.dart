import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/routing/app_routes.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/recover_pin_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/welcome_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/products/domain/product.dart';
import '../features/products/presentation/pages/product_create_page.dart';
import '../features/products/presentation/pages/product_edit_page.dart';
import '../features/products/presentation/pages/restock_page.dart';
import '../features/products/presentation/pages/stock_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'home_shell.dart';

/// Rotas do app. A sessão decide para onde ir: sem login, só as telas de autenticação.
GoRouter buildRouter(SessionController session) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: session,
    redirect: (context, state) => _redirect(session.status, state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: AppRoutes.welcome, builder: (_, _) => const WelcomePage()),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, state) => LoginPage(initialPhone: _stringExtra(state)),
      ),
      GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterPage()),
      GoRoute(
        path: AppRoutes.recoverPin,
        builder: (_, state) => RecoverPinPage(initialPhone: _stringExtra(state)),
      ),
      // Cada aba fica viva ao trocar de aba: sem recarregar a lista nem perder a rolagem
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                // A rota só abre com sessão ativa, então o comerciante já está carregado aqui
                builder: (_, _) => DashboardPage(merchantName: session.merchant?.name),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stock,
                builder: (_, state) => StockPage(filter: _stockFilter(state.uri.queryParameters[AppRoutes.stockFilterParam])),
              ),
            ],
          ),
        ],
      ),
      // Fora do shell: telas de tarefa ocupam a tela toda, como no protótipo
      GoRoute(path: AppRoutes.productNew, builder: (_, _) => const ProductCreatePage()),
      // Sair é decidido pela sessão (app), por isso chega como callback
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => SettingsPage(onLogout: session.logout),
      ),
      GoRoute(
        path: '/stock/:id/edit',
        builder: (_, state) => ProductEditPage(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/stock/:id/restock',
        builder: (_, state) => RestockPage(productId: state.pathParameters['id']!),
      ),
    ],
  );
}

String? _redirect(SessionStatus status, String location) {
  final isAuthRoute = AppRoutes.authRoutes.contains(location);
  return switch (status) {
    SessionStatus.restoring || SessionStatus.restoreFailed => location == AppRoutes.splash ? null : AppRoutes.splash,
    SessionStatus.signedOut => isAuthRoute ? null : AppRoutes.welcome,
    SessionStatus.signedIn => isAuthRoute || location == AppRoutes.splash ? AppRoutes.home : null,
  };
}

String? _stringExtra(GoRouterState state) {
  final extra = state.extra;
  return extra is String ? extra : null;
}

StockFilter _stockFilter(String? value) => switch (value) {
  'low' => StockFilter.low,
  'out' => StockFilter.out,
  _ => StockFilter.all,
};

/// Para os testes abrirem o app numa rota específica.
@visibleForTesting
String? redirectFor(SessionStatus status, String location) => _redirect(status, location);
