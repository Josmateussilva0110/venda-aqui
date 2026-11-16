import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_codes.dart';
import '../../../../core/network/app_failure.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/delete_action_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/customer.dart';
import '../../domain/customers_repository.dart';
import '../controllers/customer_edit_controller.dart';
import '../forms/customer_form.dart';

/// Como a edição terminou; a conta recarrega ao salvar e sai junto quando o cliente foi excluído.
enum CustomerEditResult { saved, deleted }

/// Edição de nome e telefone do cliente, e a exclusão. Volta com [CustomerEditResult] quando algo mudou.
class CustomerEditPage extends StatelessWidget {
  const CustomerEditPage({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CustomerEditController(context.read<CustomersRepository>(), customer.id),
      child: _EditView(customer: customer),
    );
  }
}

class _EditView extends StatelessWidget {
  const _EditView({required this.customer});

  final Customer customer;

  Future<ValidationFailure?> _save(BuildContext context, CustomerInput input) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await context.read<CustomerEditController>().save(input);
      messenger.showAppToast(l10n.customerUpdated);
      router.pop(CustomerEditResult.saved);
      return null;
    } on AppFailure catch (failure) {
      if (customerFieldFailure(failure, ApiCodes.customerPhoneTaken) case final fieldFailure?) return fieldFailure;
      messenger.showAppToast(failureMessage(l10n, failure), tone: ToastTone.error);
      return null;
    }
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<CustomerEditController>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.customerDeleteConfirmTitle,
      message: l10n.customerDeleteConfirmMessage(customer.name),
      confirmLabel: l10n.customerDeleteConfirm,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await controller.delete();
      messenger.showAppToast(l10n.customerDeleted);
      router.pop(CustomerEditResult.deleted);
    } on AppFailure catch (failure) {
      // Cliente com fiado no histórico: a mensagem do servidor explica por que não dá
      messenger.showAppToast(failureMessage(l10n, failure), tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final isSaving = context.select<CustomerEditController, bool>((controller) => controller.isSaving);
    final isDeleting = context.select<CustomerEditController, bool>((controller) => controller.isDeleting);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: l10n.customerEditTitle,
              onBack: () => context.pop(),
              buttonBackground: context.colors.surface,
              action: DeleteActionButton(tooltip: l10n.customerDelete, isDeleting: isDeleting, onPressed: () => _delete(context)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(spacing.xl, spacing.md, spacing.xl, spacing.xxl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomerForm(
                          initialValue: CustomerInput(name: customer.name, phone: customer.phone),
                          submitLabel: l10n.customerUpdate,
                          isSaving: isSaving,
                          onSubmit: (input) => _save(context, input),
                        ),
                        SizedBox(height: spacing.md),
                        Text(l10n.customerEditHint, style: context.text.bodySmall),
                      ],
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
