import 'package:flutter/material.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';

/// Nome e telefone do cliente, usado no cadastro e na edição. Não sabe qual dos dois é:
/// quem usa decide o texto do botão e o que fazer com o [CustomerInput].
class CustomerForm extends StatefulWidget {
  const CustomerForm({
    super.key,
    this.initialValue,
    required this.submitLabel,
    required this.isSaving,
    required this.onSubmit,
    this.onCancel,
  });

  /// Nulo no cadastro. O telefone vem como a API devolve (+55DDDNÚMERO) ou vazio.
  final CustomerInput? initialValue;
  final String submitLabel;
  final bool isSaving;

  /// Devolve a falha por campo (do servidor) para marcar os campos, ou nulo.
  final Future<ValidationFailure?> Function(CustomerInput input) onSubmit;

  /// Nulo esconde o botão de cancelar (a tela já tem o voltar).
  final VoidCallback? onCancel;

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  static const _minNameLength = 2;

  late final _nameController = TextEditingController(text: widget.initialValue?.name ?? '');
  late final _phoneController = TextEditingController(text: _initialPhone());
  final _phoneFormatter = PhoneInputFormatter();
  String? _nameError;
  String? _phoneError;

  String _initialPhone() {
    final phone = widget.initialValue?.phone ?? '';
    return phone.isEmpty ? '' : PhoneFormat.fromE164(phone);
  }

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
    final onCancel = widget.onCancel;
    final submit = AppButton(label: widget.submitLabel, compact: onCancel != null, isLoading: widget.isSaving, onPressed: _submit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        if (onCancel == null)
          submit
        else
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppButton(label: l10n.cancel, variant: AppButtonVariant.outlined, compact: true, onPressed: onCancel),
              ),
              SizedBox(width: spacing.sm),
              Expanded(flex: 3, child: submit),
            ],
          ),
      ],
    );
  }
}

/// Telefone já usado por outro cliente vira erro no campo, não aviso solto: é ali que se corrige.
ValidationFailure? customerFieldFailure(AppFailure failure, String phoneTakenCode) {
  return switch (failure) {
    ValidationFailure() => failure,
    RequestFailure(:final code, :final message) when code == phoneTakenCode => ValidationFailure({'phone': message}),
    _ => null,
  };
}
