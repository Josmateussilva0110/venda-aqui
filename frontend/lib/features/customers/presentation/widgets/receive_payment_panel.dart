import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../controllers/customer_account_controller.dart';
import 'settlement_method_label.dart';

/// Recebimento do fiado: valor (com atalhos), forma de pagamento e quanto vai sobrar.
class ReceivePaymentPanel extends StatefulWidget {
  const ReceivePaymentPanel({
    super.key,
    required this.balanceCents,
    required this.initialAmountCents,
    required this.isSaving,
    required this.validate,
    required this.onSubmit,
    required this.onCancel,
  });

  final int balanceCents;

  /// Pré-preenchido com a dívida toda em "Receber tudo"; vazio em "Receber parte".
  final int? initialAmountCents;
  final bool isSaving;
  final PaymentIssue? Function(int? amountCents) validate;
  final void Function(int amountCents, SettlementMethod method) onSubmit;
  final VoidCallback onCancel;

  @override
  State<ReceivePaymentPanel> createState() => _ReceivePaymentPanelState();
}

class _ReceivePaymentPanelState extends State<ReceivePaymentPanel> {
  // Atalhos em reais, como no protótipo; só aparecem os menores que a dívida
  static const _quickAmountsCents = [1000, 2000, 5000];

  late final _amountController = TextEditingController(
    text: widget.initialAmountCents == null ? '' : MoneyFormat.toInput(widget.initialAmountCents!),
  );
  SettlementMethod _method = SettlementMethod.cash;
  PaymentIssue? _issue;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? get _amountCents => MoneyFormat.parseCents(_amountController.text);

  void _setAmount(int cents) {
    _amountController.text = MoneyFormat.toInput(cents);
    setState(() => _issue = null);
  }

  void _submit() {
    final amount = _amountCents;
    final issue = widget.validate(amount);
    setState(() => _issue = issue);
    if (issue == null && amount != null) widget.onSubmit(amount, _method);
  }

  String _remainingLabel(AppLocalizations l10n) {
    final amount = _amountCents ?? 0;
    if (amount > widget.balanceCents) return l10n.receiveExceedsBalance;
    if (amount == widget.balanceCents) return l10n.receiveSettles;
    return l10n.receiveRemaining(MoneyFormat.format(widget.balanceCents - amount));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final half = (widget.balanceCents / 2).round();
    final issueMessage = switch (_issue) {
      PaymentIssue.invalidAmount => l10n.receiveInvalidAmount,
      PaymentIssue.exceedsBalance => l10n.receiveExceedsBalance,
      null => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.receiveAmountQuestion, style: context.text.labelMedium),
        SizedBox(height: spacing.xs),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
          onChanged: (_) => setState(() => _issue = null),
          style: context.text.headlineSmall,
          decoration: InputDecoration(prefixText: r'R$ ', hintText: '0,00', errorText: issueMessage),
        ),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: spacing.xs + 2,
          runSpacing: spacing.xs + 2,
          children: [
            for (final cents in _quickAmountsCents.where((cents) => cents < widget.balanceCents))
              FilterPill(label: MoneyFormat.format(cents), selected: _amountCents == cents, onTap: () => _setAmount(cents)),
            if (half > 0 && half < widget.balanceCents)
              FilterPill(label: l10n.receiveHalf, selected: _amountCents == half, onTap: () => _setAmount(half)),
          ],
        ),
        SizedBox(height: spacing.sm),
        Row(
          children: [
            Expanded(child: Text(l10n.receiveCurrentDebt(MoneyFormat.format(widget.balanceCents)), style: context.text.bodySmall)),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                _remainingLabel(l10n),
                textAlign: TextAlign.end,
                style: context.text.labelMedium?.copyWith(
                  color: (_amountCents ?? 0) > widget.balanceCents ? colors.danger : colors.successStrong,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        Text(l10n.receiveMethodQuestion, style: context.text.labelMedium),
        SizedBox(height: spacing.xs),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            for (final method in SettlementMethod.values)
              FilterPill(label: method.label(l10n), selected: _method == method, onTap: () => setState(() => _method = method)),
          ],
        ),
        SizedBox(height: spacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppButton(label: l10n.cancel, variant: AppButtonVariant.outlined, compact: true, onPressed: widget.onCancel),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              flex: 3,
              child: AppButton(label: l10n.receiveConfirm, compact: true, isLoading: widget.isSaving, onPressed: _submit),
            ),
          ],
        ),
      ],
    );
  }
}
