import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/stock/stock_changes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/stock_overview.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/credit_summary_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/revenue_card.dart';
import '../widgets/shortcut_tile.dart';
import '../widgets/stock_alerts_card.dart';
import '../widgets/today_sales_card.dart';

/// Início. O nome do comerciante vem do app (sessão), sem depender da feature de login.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.merchantName});

  /// Nome do comércio ou vendedor da sessão; vem do app para o início não depender da feature de login.
  final String? merchantName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardController(context.read<DashboardRepository>(), context.read<StockChanges>())..load(),
      child: _DashboardView(merchantName: merchantName),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.merchantName});

  final String? merchantName;

  // O resumo se atualiza sozinho pelo aviso de mudança no estoque (DashboardController)
  void _push(BuildContext context, String location) => context.push(location);

  // Pagamento recebido não passa pelo aviso de estoque: confere o fiado ao voltar, se mudou algo
  Future<void> _openCredit(BuildContext context) async {
    final controller = context.read<DashboardController>();
    final changed = await context.push<bool>(AppRoutes.customers);
    if (changed == true) await controller.loadCredit();
  }

  void _openStock(BuildContext context, {String? filter}) {
    context.go(AppRoutes.stockFiltered(filter));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<DashboardController>();
    final overview = controller.overview;
    final spacing = context.spacing;
    final colors = context.colors;
    final restockFilter = (overview?.outCount ?? 0) > 0 ? 'out' : 'low';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(spacing.xl, spacing.lg, spacing.xl, spacing.xxl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeader(now: DateTime.now(), merchantName: merchantName, onSettings: () => context.push(AppRoutes.settings)),
                    SizedBox(height: spacing.xl),
                    if (controller.todaySales case final sales?)
                      RevenueCard(sales: sales, onTap: () => context.push(AppRoutes.salesHistory))
                    else if (controller.salesFailure case final failure?)
                      ErrorView(message: failureMessage(l10n, failure), onRetry: controller.loadSales)
                    else
                      const LoadingView(),
                    SizedBox(height: spacing.lg),
                    AppButton(
                      label: l10n.dashboardRegisterSale,
                      icon: Icons.add_shopping_cart_rounded,
                      onPressed: () => context.go(AppRoutes.sell),
                    ),
                    if (controller.credit case final credit?) ...[
                      SizedBox(height: spacing.md),
                      CreditSummaryCard(credit: credit, onTap: () => _openCredit(context)),
                    ],
                    SizedBox(height: spacing.xxl - 2),
                    SectionHeader(title: l10n.shortcutsTitle),
                    SizedBox(height: spacing.md),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ShortcutTile(
                              label: l10n.shortcutRestock,
                              icon: Icons.move_to_inbox_rounded,
                              tint: colors.warningSoft,
                              ink: colors.warning,
                              onTap: () => _openStock(context, filter: restockFilter),
                            ),
                          ),
                          SizedBox(width: spacing.sm + 2),
                          Expanded(
                            child: ShortcutTile(
                              label: l10n.shortcutNewProduct,
                              icon: Icons.add_box_rounded,
                              tint: colors.primarySoft,
                              ink: colors.primary,
                              onTap: () => _push(context, AppRoutes.productNew),
                            ),
                          ),
                          SizedBox(width: spacing.sm + 2),
                          Expanded(
                            child: ShortcutTile(
                              label: l10n.shortcutSalesHistory,
                              icon: Icons.receipt_long_rounded,
                              tint: colors.successSoft,
                              ink: colors.success,
                              onTap: () => context.push(AppRoutes.salesHistory),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (overview != null)
                      ..._alertsSection(context, overview)
                    else if (controller.failure case final failure?)
                      ErrorView(message: failureMessage(l10n, failure), onRetry: controller.loadStock),
                    if (controller.todaySales case final sales?) ...[
                      SizedBox(height: spacing.xxl - 2),
                      SectionHeader(
                        title: l10n.dashboardTodaySalesTitle,
                        actionLabel: l10n.dashboardSeeHistory,
                        onAction: () => context.push(AppRoutes.salesHistory),
                      ),
                      SizedBox(height: spacing.md),
                      TodaySalesCard(sales: sales.recent, onOpen: (sale) => context.push(AppRoutes.sale(sale.id))),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _alertsSection(BuildContext context, StockOverview overview) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    if (overview.totalProducts == 0) {
      return [EmptyView(message: l10n.dashboardNoProducts)];
    }
    if (overview.alerts.isEmpty) return const [];
    return [
      SizedBox(height: spacing.xxl - 2),
      SectionHeader(
        title: l10n.stockAlertsTitle,
        actionLabel: l10n.seeAll,
        onAction: () => _openStock(context, filter: overview.outCount > 0 && overview.lowCount == 0 ? 'out' : 'low'),
      ),
      SizedBox(height: spacing.md),
      StockAlertsCard(alerts: overview.alerts, onRestock: (alert) => _push(context, AppRoutes.productRestock(alert.productId))),
    ];
  }
}
