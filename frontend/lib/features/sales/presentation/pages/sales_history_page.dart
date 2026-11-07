import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/date_range_fields.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';
import '../../domain/sales_repository.dart';
import '../controllers/sales_history_controller.dart';
import '../widgets/payment_method_style.dart';

class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SalesHistoryController(context.read<SalesRepository>())..load(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  // Carrega a próxima página quando faltar menos que isto para o fim da lista
  static const _loadMoreExtent = 400.0;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = context.read<SalesHistoryController>();
    // Depois de uma falha, só tenta de novo pelo botão do rodapé, não a cada arrasto
    if (controller.loadMoreFailure != null) return;
    if (_scrollController.position.extentAfter < _loadMoreExtent) controller.loadMore();
  }

  // Só busca de novo se a venda foi editada, e sem limpar a tela (a rolagem fica onde estava)
  Future<void> _open(Sale sale) async {
    final controller = context.read<SalesHistoryController>();
    final edited = await context.push<bool>(AppRoutes.sale(sale.id));
    if (edited == true) await controller.load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<SalesHistoryController>();
    final groups = controller.groups;
    final locale = Localizations.localeOf(context).toString();
    final formats = (day: DateFormat.MMMEd(locale), time: DateFormat.Hm(locale));
    // Cabeçalhos de dia e vendas numa lista só: o ListView monta só as linhas visíveis,
    // mesmo num dia com centenas de vendas
    final entries = [
      for (final group in groups) ...[
        _HistoryEntry.header(group),
        for (final (index, sale) in group.sales.indexed)
          _HistoryEntry.sale(sale, isFirst: index == 0, isLast: index == group.sales.length - 1),
      ],
    ];

    final Widget? placeholder = switch (controller.status) {
      HistoryStatus.loading => const LoadingView(),
      HistoryStatus.failure => ErrorView(message: failureMessage(l10n, controller.failure!), onRetry: controller.load),
      HistoryStatus.invalidRange => EmptyView(message: l10n.historyInvalidRange),
      HistoryStatus.ready when groups.isEmpty => EmptyView(message: l10n.historyEmpty),
      HistoryStatus.ready => null,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(title: l10n.historyTitle, onBack: () => context.pop(), buttonBackground: context.colors.surface),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
                  child: RefreshIndicator(
                    onRefresh: controller.load,
                    // Os filtros rolam junto com a lista: em celular deitado não sobraria espaço para as vendas
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xl),
                      itemCount: 1 + (placeholder != null ? 1 : entries.length + 1),
                      itemBuilder: (context, index) {
                        if (index == 0) return _HistoryFilters(searchController: _searchController);
                        if (placeholder != null) return placeholder;
                        if (index == entries.length + 1) {
                          return PaginationFooter(
                            hasMore: controller.hasMore,
                            isLoadingMore: controller.isLoadingMore,
                            failure: controller.loadMoreFailure,
                            onLoadMore: controller.loadMore,
                            onRetry: controller.retryLoadMore,
                          );
                        }
                        return switch (entries[index - 1]) {
                          _HistoryEntry(:final group?) => _DayHeader(group: group, today: controller.today, format: formats.day),
                          _HistoryEntry(:final sale?, :final isFirst, :final isLast) => _SaleRow(
                            sale: sale,
                            timeFormat: formats.time,
                            isFirst: isFirst,
                            isLast: isLast,
                            onTap: () => _open(sale),
                          ),
                          _ => const SizedBox.shrink(),
                        };
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resumo, período, busca e forma de pagamento. Reconstrói só quando o filtro ou o resumo muda.
class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.read<SalesHistoryController>();
    final (period, method, count, total) = context.select<SalesHistoryController, (HistoryPeriod, PaymentMethod?, int, int)>(
      (history) => (history.period, history.method, history.saleCount, history.totalCents),
    );
    final periods = [
      (HistoryPeriod.today, l10n.historyToday),
      (HistoryPeriod.week, l10n.historyWeek),
      (HistoryPeriod.month, l10n.historyMonth),
      (HistoryPeriod.custom, l10n.historyCustom),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.historySummary(l10n.historySaleCount(count), MoneyFormat.format(total)), style: context.text.bodyMedium),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              for (final (value, label) in periods)
                FilterPill(label: label, selected: period == value, onTap: () => controller.selectPeriod(value)),
            ],
          ),
          if (period == HistoryPeriod.custom) ...[SizedBox(height: spacing.md), const _CustomRange()],
          SizedBox(height: spacing.md),
          SearchField(controller: searchController, hint: l10n.historySearchHint, onChanged: controller.search),
          SizedBox(height: spacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterPill(label: l10n.historyAllMethods, selected: method == null, onTap: () => controller.selectMethod(null)),
                for (final value in PaymentMethod.values) ...[
                  SizedBox(width: spacing.sm),
                  FilterPill(label: value.label(l10n), selected: method == value, onTap: () => controller.selectMethod(value)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Período personalizado do histórico.
class _CustomRange extends StatelessWidget {
  const _CustomRange();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SalesHistoryController>();
    final (from, to) = context.select<SalesHistoryController, (DateTime, DateTime)>((history) => (history.customFrom, history.customTo));
    return DateRangeFields(
      from: from,
      to: to,
      lastDate: controller.today,
      onFromChanged: (date) => controller.setCustomRange(from: date),
      onToChanged: (date) => controller.setCustomRange(to: date),
    );
  }
}

/// Item da lista do histórico: cabeçalho de um dia ou uma venda.
class _HistoryEntry {
  const _HistoryEntry.header(SaleDayGroup this.group) : sale = null, isFirst = false, isLast = false;
  const _HistoryEntry.sale(Sale this.sale, {required this.isFirst, required this.isLast}) : group = null;

  final SaleDayGroup? group;
  final Sale? sale;

  /// Primeira e última venda do dia: arredondam os cantos do cartão do dia.
  final bool isFirst;
  final bool isLast;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.group, required this.today, required this.format});

  final SaleDayGroup group;
  final DateTime today;
  final DateFormat format;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final days = today.difference(group.day).inDays;
    final label = switch (days) {
      0 => l10n.historyToday,
      1 => l10n.historyYesterday,
      _ => toBeginningOfSentenceCase(format.format(group.day)),
    };
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.xs, spacing.md, spacing.xs, spacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.text.titleSmall)),
          Text(
            l10n.historySummary(l10n.historySaleCount(group.sales.length), MoneyFormat.format(group.totalCents)),
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Uma venda; as vendas do mesmo dia formam um cartão contínuo, com cantos só nas pontas.
class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale, required this.timeFormat, required this.isFirst, required this.isLast, required this.onTap});

  final Sale sale;
  final DateFormat timeFormat;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final colors = context.colors;
    final time = timeFormat.format(sale.createdAt);
    final radius = Radius.circular(context.radius.xxl);
    final shape = BorderRadius.vertical(top: isFirst ? radius : Radius.zero, bottom: isLast ? radius : Radius.zero);
    return Material(
      color: colors.surface,
      borderRadius: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: isFirst ? null : Border(top: BorderSide(color: colors.divider)),
          ),
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Row(
              children: [
                Text(time, style: context.text.labelMedium?.copyWith(color: context.colors.muted)),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.items.map((item) => item.name).join(', '),
                        style: context.text.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        sale.customer?.name ?? l10n.historyProductCount(sale.items.length),
                        style: context.text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(MoneyFormat.format(sale.totalCents), style: context.text.titleSmall),
                    SizedBox(height: spacing.xxs),
                    PaymentMethodBadge(method: sale.method),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
