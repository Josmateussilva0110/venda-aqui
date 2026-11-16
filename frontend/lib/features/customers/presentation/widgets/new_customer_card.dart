import 'package:flutter/material.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../forms/customer_form.dart';

/// Cadastro rápido de cliente dentro da venda fiado: só nome e telefone.
class NewCustomerCard extends StatelessWidget {
  const NewCustomerCard({super.key, required this.initialName, required this.isSaving, required this.onSubmit, required this.onCancel});

  /// O que o comerciante já digitou na busca, para não digitar de novo.
  final String initialName;
  final bool isSaving;

  /// Devolve a falha de validação do servidor (por campo) para marcar os campos, ou nulo.
  final Future<ValidationFailure?> Function(CustomerInput input) onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return AppCard(
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.customerNewTitle, style: context.text.titleMedium),
          SizedBox(height: spacing.md),
          CustomerForm(
            initialValue: initialName.isEmpty ? null : CustomerInput(name: initialName, phone: ''),
            submitLabel: l10n.customerSave,
            isSaving: isSaving,
            onSubmit: onSubmit,
            onCancel: onCancel,
          ),
        ],
      ),
    );
  }
}
