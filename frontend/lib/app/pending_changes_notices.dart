import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/offline/outbox.dart';
import '../core/widgets/app_feedback.dart';
import '../features/customers/data/pending_payment_sender.dart';
import '../features/customers/presentation/widgets/pending_payment_notice.dart';
import '../features/products/data/pending_restock_sender.dart';
import '../features/products/presentation/widgets/pending_restock_notice.dart';
import '../features/sales/data/pending_sale_sender.dart';
import '../features/sales/presentation/widgets/pending_sale_notice.dart';
import '../l10n/app_localizations.dart';

/// Avisa o que aconteceu com as alterações feitas sem internet quando elas sobem: recusa, falta de
/// estoque ou a fila esvaziou. Fica em volta das abas para valer em qualquer tela; cada feature
/// só diz o texto do seu aviso.
class PendingChangesNotices extends StatefulWidget {
  const PendingChangesNotices({super.key, required this.child});

  final Widget child;

  @override
  State<PendingChangesNotices> createState() => _PendingChangesNoticesState();
}

class _PendingChangesNoticesState extends State<PendingChangesNotices> {
  late final Outbox _outbox;
  StreamSubscription<OutboxEvent>? _subscription;
  int _lastPending = 0;

  @override
  void initState() {
    super.initState();
    _outbox = context.read<Outbox>();
    _lastPending = _outbox.pendingCount;
    _subscription = _outbox.events.listen(_onEvent);
    _outbox.addListener(_onCountsChanged);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _outbox.removeListener(_onCountsChanged);
    super.dispose();
  }

  void _onEvent(OutboxEvent event) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final message = switch (event.kind) {
      PendingSaleSender.kind => pendingSaleNotice(l10n, event, _formatMoment),
      PendingPaymentSender.kind => pendingPaymentNotice(l10n, event),
      PendingRestockSender.kind => pendingRestockNotice(l10n, event),
      _ => null,
    };
    if (message != null) showAppToast(context, message, tone: ToastTone.error);
  }

  // A fila esvaziou: tudo o que foi feito sem internet chegou ao servidor
  void _onCountsChanged() {
    final pending = _outbox.pendingCount;
    if (_lastPending > 0 && pending == 0 && _outbox.rejectedCount == 0 && mounted) {
      showAppToast(context, AppLocalizations.of(context).pendingChangesSent);
    }
    _lastPending = pending;
  }

  String _formatMoment(DateTime moment) => DateFormat('dd/MM HH:mm', Localizations.localeOf(context).toString()).format(moment);

  @override
  Widget build(BuildContext context) => widget.child;
}
