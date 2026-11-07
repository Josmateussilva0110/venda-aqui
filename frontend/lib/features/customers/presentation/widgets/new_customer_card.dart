import 'package:flutter/material.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';

/// Cadastro rápido de cliente dentro da venda fiado: só nome e telefone.
class NewCustomerCard extends StatefulWidget {
  const NewCustomerCard({super.key, required this.initialName, required this.isSaving, required this.onSubmit, required this.onCancel});

  /// O que o comerciante já digitou na busca, para não digitar de novo.
  final String initialName;
  final bool isSaving;

  /// Devolve a falha de validação do servidor (por campo) para marcar os campos, ou nulo.
  final Future<ValidationFailure?> Function(CustomerInput input) onSubmit;
  final VoidCallback onCancel;

  @override
  State<NewCustomerCard> createState() => _NewCustomerCardState();
}

class _NewCustomerCardState extends State<NewCustomerCard> {
  static const _minNameLength = 2;

  late final _nameController = TextEditingController(text: widget.initialName);
  final _phoneController = TextEditingController();
  final _phoneFormatter = PhoneInputFormatter();
  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final phone = PhoneFormat.digitsOnly(_phoneController.text);
    // Conferência de UX; o servidor valida de novo e normaliza o telefone
    setState(() {
      _nameError = name.length < _minNameLength ? l10n.customerNameInvalid : null;
      _phoneError = PhoneFormat.isComplete(phone) ? null : l10n.customerPhoneInvalid;
    });
    if (_nameError != null || _phoneError != null) return;

    final failure = await widget.onSubmit(CustomerInput(name: name, phone: phone));
    if (!mounted || failure == null) return;
    setState(() {
      _nameError = failure['name'];
      _phoneError = failure['phone'];
    });
  }

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
          LabeledField(
            label: l10n.customerNameLabel,
            child: TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(hintText: l10n.customerNamePlaceholder, errorText: _nameError),
            ),
          ),
          SizedBox(height: spacing.md),
          LabeledField(
            label: l10n.customerPhoneLabel,
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [_phoneFormatter],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(hintText: l10n.phonePlaceholder, errorText: _phoneError),
            ),
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
                child: AppButton(label: l10n.customerSave, compact: true, isLoading: widget.isSaving, onPressed: _submit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
