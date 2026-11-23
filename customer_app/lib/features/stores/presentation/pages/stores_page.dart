import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/stores_repository.dart';
import '../controllers/stores_controller.dart';
import '../widgets/store_card.dart';
import '../widgets/stores_header.dart';

/// Início do cliente: as lojas ligadas ao acesso e o que ele deve em cada uma.
class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StoresController(context.read<StoresRepository>())..load(),
      child: const _StoresView(),
    );
  }
}

class _StoresView extends StatelessWidget {
  const _StoresView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<StoresController>();
    final spacing = context.spacing;
    final state = controller.state;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.load(silent: true),
          child: ResponsiveBody(
            maxWidth: AppBreakpoints.listMaxWidth,
            child: CustomScrollView(
              // Sempre rolável, senão o "puxar para atualizar" não funciona com poucas lojas
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(spacing.xl, spacing.lg, spacing.xl, spacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: StoresHeader(
                      onAddStore: () => context.push(AppRoutes.pasteInvite),
                      onOpenSettings: () => context.push(AppRoutes.settings),
                    ),
                  ),
                ),
                switch (state) {
                  StoresLoading() => const SliverToBoxAdapter(child: LoadingView()),
                  StoresFailed(:final failure) => SliverToBoxAdapter(
                    child: ErrorView(message: failureMessage(l10n, failure), onRetry: controller.load),
                  ),
                  StoresLoaded(:final stores) when stores.isEmpty => SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
                      child: EmptyView(message: l10n.storesEmpty),
                    ),
                  ),
                  StoresLoaded(:final stores) => SliverPadding(
                    padding: EdgeInsets.fromLTRB(spacing.xl, 0, spacing.xl, spacing.xl),
                    sliver: SliverList.separated(
                      itemCount: stores.length,
                      separatorBuilder: (_, _) => SizedBox(height: spacing.md),
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        return StoreCard(
                          store: store,
                          onTap: () => context.push(AppRoutes.storeStatement(store.id), extra: store),
                        );
                      },
                    ),
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
