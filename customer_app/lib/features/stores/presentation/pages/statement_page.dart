import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/store.dart';
import '../../domain/stores_repository.dart';
import '../controllers/statement_controller.dart';
import '../widgets/statement_entry_tile.dart';
import '../widgets/store_card.dart';

/// Compras fiado e pagamentos numa loja, do mais recente para o mais antigo.
class StatementPage extends StatelessWidget {
  const StatementPage({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StatementController(context.read<StoresRepository>(), storeId: store.id)..loadFirst(),
      child: _StatementView(store: store),
    );
  }
}

class _StatementView extends StatelessWidget {
  const _StatementView({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(store.merchantName, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: SafeArea(
        top: false,
        child: ResponsiveBody(
          maxWidth: AppBreakpoints.listMaxWidth,
          child: _StatementList(store: store),
        ),
      ),
    );
  }
}

class _StatementList extends StatelessWidget {
  const _StatementList({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<StatementController>();
    final spacing = context.spacing;
    final items = controller.items;
    final firstPageFailure = controller.firstPageFailure;

    final Widget body;
    if (controller.isLoadingFirst) {
      body = const SliverToBoxAdapter(child: LoadingView());
    } else if (firstPageFailure != null) {
      body = SliverToBoxAdapter(
        child: ErrorView(message: failureMessage(l10n, firstPageFailure), onRetry: controller.loadFirst),
      );
    } else if (items.isEmpty) {
      body = SliverToBoxAdapter(child: EmptyView(message: l10n.statementEmpty));
    } else {
      body = SliverList.separated(
        // O último item é o rodapé: ao aparecer na tela, ele pede a próxima página
        itemCount: items.length + 1,
        separatorBuilder: (_, _) => Divider(height: 1, color: context.colors.divider),
        itemBuilder: (context, index) => index < items.length
            ? StatementEntryTile(entry: items[index])
            : PaginationFooter(
                hasMore: controller.hasMore,
                isLoadingMore: controller.isLoadingMore,
                failure: controller.nextPageFailure,
                onLoadMore: controller.loadMore,
                onRetry: controller.retryMore,
              ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(spacing.xl, spacing.lg, spacing.xl, 0),
          sliver: SliverToBoxAdapter(child: StoreBalance(store: store)),
        ),
        SliverPadding(padding: EdgeInsets.fromLTRB(spacing.xl, spacing.md, spacing.xl, spacing.xl), sliver: body),
      ],
    );
  }
}
