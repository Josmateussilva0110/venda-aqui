import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/stock/stock_changes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/date_range_fields.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sales_report.dart';
import '../controllers/reports_controller.dart';
import '../widgets/period_selector.dart';
import '../widgets/profit_breakdown_card.dart';
import '../widgets/profit_card.dart';
import '../widgets/profit_ranking_card.dart';

/// Relatórios: lucro líquido real do período e os produtos que mais dão lucro.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReportsController(context.read<ReportsRepository>(), context.read<StockChanges>())..load(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // As abas escondidas ficam com os tickers desligados: ligar de novo é sinal de que a aba apareceu
    if (!TickerMode.valuesOf(context).enabled) return;
    // Depois do frame: recarregar notifica, e aqui ainda estamos no meio do build
    final controller = context.read<ReportsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.refreshIfStale();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<ReportsController>();
    final report = controller.report;

    final List<Widget> body;
    if (report != null) {
      body = [
        ProfitCard(report: report),
        SizedBox(height: spacing.md),
        ProfitBreakdownCard(report: report),
        SizedBox(height: spacing.md),
        ProfitRankingCard(ranking: report.ranking),
      ];
    } else if (controller.failure case final failure?) {
      body = [ErrorView(message: failureMessage(l10n, failure), onRetry: controller.load)];
    } else {
      body = const [LoadingView()];
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.xxl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _ReportsHeader(),
                    SizedBox(height: spacing.lg),
                    ...body,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Título, período por extenso e escolha do período.
class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader();

  String _rangeLabel(BuildContext context, ReportsController controller) {
    final l10n = AppLocalizations.of(context);
    final format = DateFormat.MMMd(Localizations.localeOf(context).toString());
    final (from, to) = controller.range;
    if (controller.period == ReportPeriod.today) return l10n.reportsRangeToday(format.format(from));
    if (from == to) return format.format(from);
    return l10n.reportsRange(format.format(from), format.format(to));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final controller = context.watch<ReportsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.reportsTitle, style: context.text.headlineMedium),
        Text(_rangeLabel(context, controller), style: context.text.bodyMedium),
        SizedBox(height: spacing.md),
        PeriodSelector(selected: controller.period, onSelected: controller.selectPeriod),
        if (controller.period == ReportPeriod.custom) ...[
          SizedBox(height: spacing.md),
          DateRangeFields(
            from: controller.customFrom,
            to: controller.customTo,
            lastDate: controller.today,
            onFromChanged: (date) => controller.setCustomRange(from: date),
            onToChanged: (date) => controller.setCustomRange(to: date),
          ),
          if (controller.isRangeSwapped) ...[
            SizedBox(height: spacing.xs),
            Text(l10n.reportsRangeSwapped, style: context.text.bodySmall?.copyWith(color: colors.warning)),
          ],
        ],
      ],
    );
  }
}
