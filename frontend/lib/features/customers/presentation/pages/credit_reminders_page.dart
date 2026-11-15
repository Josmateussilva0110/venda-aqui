import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/notifications/reminder_notifier.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';
import '../controllers/credit_reminders_controller.dart';
import '../widgets/customer_whatsapp_button.dart';
import '../widgets/reminder_tile.dart';

/// Lembretes do fiado a enviar hoje. Cada envio abre o WhatsApp com a mensagem pronta;
/// quem aperta enviar é o comerciante.
class CreditRemindersPage extends StatelessWidget {
  const CreditRemindersPage({super.key, this.merchantName});

  /// Assina as mensagens; vem da sessão, pelo app.
  final String? merchantName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreditRemindersController(context.read<CustomersRepository>())..loadFirstPage(),
      child: _RemindersView(merchantName: merchantName),
    );
  }
}

class _RemindersView extends StatefulWidget {
  const _RemindersView({required this.merchantName});

  final String? merchantName;

  @override
  State<_RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<_RemindersView> {
  static const _loadMoreExtent = 400.0;

  final _scrollController = ScrollController();

  // Lembrete sendo montado (busca as compras); um por vez, contra toque duplo
  String? _sendingId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Abrir os lembretes é o momento em que o aviso faz sentido para o comerciante
    context.read<ReminderNotifier>().requestPermission();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = context.read<CreditRemindersController>();
    if (controller.loadMoreFailure != null) return;
    if (_scrollController.position.extentAfter < _loadMoreExtent) controller.loadMore();
  }

  // Só conta como enviado se o WhatsApp abriu; não dá para saber se a mensagem saiu de lá
  Future<void> _send(CreditReminder reminder) async {
    if (_sendingId != null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<CreditRemindersController>();
    setState(() => _sendingId = reminder.customer.id);
    final bool opened;
    try {
      opened = await openCustomerWhatsApp(
        context,
        reminder.customer,
        charge: true,
        status: reminder.status,
        merchantName: widget.merchantName,
      );
    } finally {
      if (mounted) setState(() => _sendingId = null);
    }
    if (!opened) return;
    try {
      await controller.markSent(reminder.customer.id);
    } on AppFailure catch (failure) {
      messenger.showAppToast(failureMessage(l10n, failure), tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<CreditRemindersController>();
    final items = controller.items;

    final Widget? placeholder = switch (controller.status) {
      RemindersStatus.loading => const LoadingView(),
      RemindersStatus.failure => ErrorView(message: failureMessage(l10n, controller.failure!), onRetry: controller.loadFirstPage),
      RemindersStatus.ready when items.isEmpty => EmptyView(message: l10n.remindersEmpty),
      RemindersStatus.ready => null,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop(controller.changed);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenHeader(
                title: l10n.remindersTitle,
                onBack: () => context.pop(controller.changed),
                buttonBackground: context.colors.surface,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.listMaxWidth),
                    child: RefreshIndicator(
                      onRefresh: controller.loadFirstPage,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xl),
                        itemCount: 1 + (placeholder != null ? 1 : items.length + 1),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: spacing.md),
                              child: Text(l10n.remindersSubtitle, style: context.text.bodyMedium),
                            );
                          }
                          if (placeholder != null) return placeholder;
                          if (index == items.length + 1) {
                            return PaginationFooter(
                              hasMore: controller.hasMore,
                              isLoadingMore: controller.isLoadingMore,
                              failure: controller.loadMoreFailure,
                              onLoadMore: controller.loadMore,
                              onRetry: controller.retryLoadMore,
                            );
                          }
                          final reminder = items[index - 1];
                          return Padding(
                            padding: EdgeInsets.only(bottom: spacing.sm),
                            child: ReminderTile(
                              reminder: reminder,
                              sent: controller.isSent(reminder.customer.id),
                              isSending: _sendingId == reminder.customer.id,
                              onSend: () => _send(reminder),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
