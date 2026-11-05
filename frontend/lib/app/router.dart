import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/routing/app_routes.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/recover_pin_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/welcome_page.dart';
import '../features/customers/presentation/pages/customer_account_page.dart';
import '../features/customers/presentation/pages/customer_picker_page.dart';
import '../features/customers/presentation/pages/debtors_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/products/domain/product.dart';
import '../features/products/presentation/pages/product_create_page.dart';
import '../features/products/presentation/pages/product_edit_page.dart';
import '../features/products/presentation/pages/restock_page.dart';
import '../features/products/presentation/pages/stock_page.dart';
import '../features/sales/domain/sale.dart';
import '../features/sales/presentation/pages/payment_page.dart';
import '../features/sales/presentation/pages/sale_detail_page.dart';
import '../features/sales/presentation/pages/sale_done_page.dart';
import '../features/sales/presentation/pages/sale_edit_page.dart';
import '../features/sales/presentation/pages/sale_summary_page.dart';
import '../features/sales/presentation/pages/sales_history_page.dart';
import '../features/sales/presentation/pages/sell_page.dart';
import '../features/sales/presentation/pages/weight_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
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
            routes: [GoRoute(path: AppRoutes.sell, builder: (_, _) => const SellPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stock,
                builder: (_, state) => StockPage(filter: _stockFilter(state.uri.queryParameters[AppRoutes.stockFilterParam])),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.reports, builder: (_, _) => const ReportsPage())],
          ),
        ],
      ),
      // Fora do shell: telas de tarefa ocupam a tela toda, como no protótipo
      GoRoute(path: AppRoutes.productNew, builder: (_, _) => const ProductCreatePage()),
      // Telas da venda: as que recebem dados por `extra` voltam ao vender se abertas sem eles
      GoRoute(
        path: AppRoutes.sellWeight,
        redirect: (_, state) => state.extra is WeightRequest ? null : AppRoutes.sell,
        builder: (_, state) => WeightPage(request: state.extra! as WeightRequest),
      ),
      GoRoute(path: AppRoutes.sellSummary, builder: (_, _) => const SaleSummaryPage()),
      GoRoute(path: AppRoutes.sellPayment, builder: (_, _) => const PaymentPage()),
      GoRoute(
        path: AppRoutes.sellDone,
        redirect: (_, state) => state.extra is Sale ? null : AppRoutes.home,
        builder: (_, state) => SaleDonePage(sale: state.extra! as Sale),
      ),
      GoRoute(path: AppRoutes.salesHistory, builder: (_, _) => const SalesHistoryPage()),
      GoRoute(
        path: '/sales/:id',
        builder: (_, state) => SaleDetailPage(saleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/sales/:id/edit',
        redirect: (_, state) => state.extra is Sale ? null : AppRoutes.sale(state.pathParameters['id']!),
        builder: (_, state) => SaleEditPage(sale: state.extra! as Sale),
      ),
      GoRoute(path: AppRoutes.customers, builder: (_, _) => const DebtorsPage()),
      // Antes de /customers/:id, senão "pick" seria lido como id
      GoRoute(
        path: AppRoutes.customerPicker,
        redirect: (_, state) => state.extra is CustomerPickerRequest ? null : AppRoutes.customers,
        builder: (_, state) {
          final request = state.extra! as CustomerPickerRequest;
          return CustomerPickerPage(
            amountCents: request.amountCents,
            itemCount: request.itemCount,
            initialCustomerId: request.initialCustomerId,
          );
        },
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (_, state) => CustomerAccountPage(customerId: state.pathParameters['id']!),
      ),
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
