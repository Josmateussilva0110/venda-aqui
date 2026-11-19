import 'package:flutter/material.dart';

import '../../../../core/network/api_codes.dart';
import '../../../../core/network/app_failure.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/cpf_format.dart';
import '../../../../core/utils/cpf_input_formatter.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';

/// Nome, telefone e CPF (opcional) do cliente, usado no cadastro e na edição. Não sabe qual dos dois é:
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

  /// Nulo no cadastro. O telefone vem como a API devolve (+55DDDNÚMERO) ou vazio; o CPF, só dígitos
  /// ou nulo (sem CPF ou não carregado).
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
  late final _cpfController = TextEditingController(text: CpfFormat.display(widget.initialValue?.cpf ?? ''));
  final _phoneFormatter = PhoneInputFormatter();
  final _cpfFormatter = CpfInputFormatter();
  String? _nameError;
  String? _phoneError;
  String? _cpfError;

  String _initialPhone() {
    final phone = widget.initialValue?.phone ?? '';
    return phone.isEmpty ? '' : PhoneFormat.fromE164(phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  // Campo vazio num cliente sem CPF conhecido não manda nada: o formulário pode ter aberto sem o CPF
  // carregado, e mandar "vazio" apagaria um CPF guardado. Apagar de propósito é esvaziar um CPF que apareceu
  String? _cpfToSend(String cpf) {
    if (cpf.isNotEmpty) return cpf;
    return widget.initialValue?.cpf == null ? null : '';
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final phone = PhoneFormat.digitsOnly(_phoneController.text);
    final cpf = CpfFormat.digitsOnly(_cpfController.text);
    // Conferência de UX; o servidor valida de novo, normaliza o telefone e confere o CPF
    setState(() {
      _nameError = name.length < _minNameLength ? l10n.customerNameInvalid : null;
      _phoneError = PhoneFormat.isComplete(phone) ? null : l10n.customerPhoneInvalid;
      _cpfError = cpf.isEmpty || CpfFormat.isValid(cpf) ? null : l10n.customerCpfInvalid;
    });
    if (_nameError != null || _phoneError != null || _cpfError != null) return;

    final failure = await widget.onSubmit(CustomerInput(name: name, phone: phone, cpf: _cpfToSend(cpf)));
    if (!mounted || failure == null) return;
    setState(() {
      _nameError = failure['name'];
      _phoneError = failure['phone'];
      _cpfError = failure['cpf'];
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
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: l10n.phonePlaceholder, errorText: _phoneError),
          ),
        ),
        SizedBox(height: spacing.md),
        LabeledField(
          label: l10n.customerCpfLabel,
          child: TextField(
            controller: _cpfController,
            keyboardType: TextInputType.number,
            inputFormatters: [_cpfFormatter],
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(hintText: l10n.customerCpfPlaceholder, errorText: _cpfError),
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

/// Telefone ou CPF já usado por outro cliente vira erro no campo, não aviso solto: é ali que se corrige.
ValidationFailure? customerFieldFailure(AppFailure failure) {
  return switch (failure) {
    ValidationFailure() => failure,
    RequestFailure(:final code, :final message) when code == ApiCodes.customerPhoneTaken => ValidationFailure({'phone': message}),
    RequestFailure(:final code, :final message) when code == ApiCodes.customerCpfTaken => ValidationFailure({'cpf': message}),
    _ => null,
  };
}
