import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/offline/outbox.dart';
import '../../../../core/offline/pending_change_text.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/pending_changes_controller.dart';
import '../widgets/pending_change_card.dart';

/// Diz como cada tipo de alteração aparece. Vem de fora: cada feature (vendas, fiado, estoque)
/// descreve as suas, e esta tela não depende delas.
typedef PendingChangeDescriber = PendingChangeText Function(AppLocalizations l10n, PendingChange change);

/// Vendas, pagamentos e reposições feitos sem internet: o que espera para subir e o que o servidor recusou.
class PendingChangesPage extends StatelessWidget {
  const PendingChangesPage({super.key, required this.describe});

  final PendingChangeDescriber describe;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PendingChangesController(context.read<Outbox>())..load(),
      child: _PendingChangesView(describe: describe),
    );
  }
}

class _PendingChangesView extends StatelessWidget {
  const _PendingChangesView({required this.describe});

  final PendingChangeDescriber describe;

  Future<void> _sendNow(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sent = await context.read<PendingChangesController>().sendNow();
    messenger.showAppToast(
      sent ? l10n.pendingChangesSent : l10n.pendingChangesStillOffline,
      tone: sent ? ToastTone.success : ToastTone.error,
    );
  }

  Future<void> _retry(BuildContext context, PendingChange change) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sent = await context.read<PendingChangesController>().retry(change.id);
    // Se voltou a ser recusada, o aviso da recusa já aparece pelos avisos gerais
    if (!sent) messenger.showAppToast(l10n.pendingChangesStillOffline, tone: ToastTone.error);
  }

  Future<void> _discard(BuildContext context, PendingChange change) async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<PendingChangesController>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.pendingChangeDiscardTitle,
      message: l10n.pendingChangeDiscardMessage(describe(l10n, change).title),
      confirmLabel: l10n.pendingChangeDiscard,
      destructive: true,
    );
    if (confirmed) await controller.discard(change.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final controller = context.watch<PendingChangesController>();
    final dateFormat = DateFormat('dd/MM HH:mm', Localizations.localeOf(context).toString());

    // Um dia inteiro sem sinal deixa centenas na fila: a lista monta só os cartões que aparecem
    Widget cards(List<PendingChange> changes) => SliverList.builder(
      itemCount: changes.length,
      itemBuilder: (context, index) {
        final change = changes[index];
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.sm + 2),
          child: PendingChangeCard(
            change: change,
            text: describe(l10n, change),
            when: dateFormat.format(change.createdAt.toLocal()),
            busy: controller.busyId == change.id,
            onRetry: () => _retry(context, change),
            onDiscard: () => _discard(context, change),
          ),
        );
      },
    );

    Widget section(String title, String hint) => SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: title),
            SizedBox(height: spacing.xs),
            Text(hint, style: context.text.bodySmall?.copyWith(color: context.colors.muted)),
          ],
        ),
      ),
    );

    final List<Widget> slivers;
    if (controller.isLoading) {
      slivers = const [SliverToBoxAdapter(child: LoadingView())];
    } else if (controller.isEmpty) {
      slivers = [SliverToBoxAdapter(child: EmptyView(message: l10n.pendingChangesEmpty))];
    } else {
      slivers = [
        if (controller.rejected.isNotEmpty) ...[
          section(l10n.pendingChangesRejectedSection(controller.rejected.length), l10n.pendingChangesRejectedHint),
          cards(controller.rejected),
          SliverToBoxAdapter(child: SizedBox(height: spacing.lg)),
        ],
        if (controller.pending.isNotEmpty) ...[
          section(l10n.pendingChangesWaitingSection(controller.pending.length), l10n.pendingChangesWaitingHint),
          cards(controller.pending),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: spacing.sm),
              child: AppButton(
                label: l10n.pendingChangesSendNow,
                icon: Icons.cloud_upload_outlined,
                isLoading: controller.isSending,
                onPressed: () => _sendNow(context),
              ),
            ),
          ),
        ],
      ];
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.pendingChangesTitle, onBack: () => context.pop(), buttonBackground: context.colors.surface),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Em tela larga a lista fica centralizada na largura de leitura
                  final side = math.max(spacing.xl, (constraints.maxWidth - AppBreakpoints.listMaxWidth) / 2);
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(side, spacing.md, side, spacing.xxl),
                        sliver: SliverMainAxisGroup(slivers: slivers),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
