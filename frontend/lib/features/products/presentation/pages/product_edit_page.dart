import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/stock/stock_changes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/delete_action_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';
import '../../domain/products_repository.dart';
import '../controllers/product_editor_controller.dart';
import '../forms/product_form.dart';

class ProductEditPage extends StatelessWidget {
  const ProductEditPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductEditorController(context.read<ProductsRepository>(), context.read<StockChanges>())..load(productId),
      child: _ProductEditView(productId: productId),
    );
  }
}

class _ProductEditView extends StatelessWidget {
  const _ProductEditView({required this.productId});

  final String productId;

  Future<void> _update(BuildContext context, ProductInput input, ProductPhoto? photo) async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<ProductEditorController>();
    final outcome = await controller.update(productId, input, photo);
    if (!context.mounted) return;
    final failure = controller.saveFailure;
    if (outcome == SaveOutcome.failed) {
      // Erro por campo (ex.: nome repetido) também marca o campo no formulário; a mensagem vem aqui
      if (failure != null) showAppToast(context, failureMessage(l10n, failure), tone: ToastTone.error);
      return;
    }
    outcome == SaveOutcome.saved
        ? showAppToast(context, l10n.productUpdated)
        : showAppToast(context, l10n.productPhotoUploadFailed, tone: ToastTone.error);
    context.pop();
  }

  Future<void> _delete(BuildContext context, Product product) async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<ProductEditorController>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.productDeleteConfirmTitle,
      message: l10n.productDeleteConfirmMessage(product.name),
      confirmLabel: l10n.productDeleteConfirm,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final deleted = await controller.delete(product.id);
    if (!context.mounted) return;
    final failure = controller.deleteFailure;
    if (!deleted) {
      if (failure != null) showAppToast(context, failureMessage(l10n, failure), tone: ToastTone.error);
      return;
    }
    showAppToast(context, l10n.productDeleted);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<ProductEditorController>();
    final product = controller.product;

    final Widget body;
    if (product != null) {
      body = ProductForm(
        initialValue: product,
        submitLabel: l10n.productSave,
        isSaving: controller.isSaving,
        serverFailure: controller.saveFailure,
        onSubmit: (input, photo) => _update(context, input, photo),
      );
    } else if (controller.loadFailure != null) {
      body = ErrorView(message: l10n.productLoadFailed, onRetry: () => controller.load(productId));
    } else {
      body = const LoadingView();
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(
              title: l10n.productEditTitle,
              onBack: () => context.pop(),
              buttonBackground: context.colors.surface,
              // Só aparece com o produto carregado: o modal mostra o nome dele
              action: product == null
                  ? null
                  : DeleteActionButton(
                      tooltip: l10n.productDelete,
                      isDeleting: controller.isDeleting,
                      onPressed: () => _delete(context, product),
                    ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
