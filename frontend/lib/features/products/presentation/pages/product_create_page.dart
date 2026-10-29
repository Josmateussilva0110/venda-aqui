import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/stock/stock_changes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';
import '../../domain/products_repository.dart';
import '../controllers/product_editor_controller.dart';
import '../forms/product_form.dart';

class ProductCreatePage extends StatelessWidget {
  const ProductCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductEditorController(context.read<ProductsRepository>(), context.read<StockChanges>()),
      child: const _ProductCreateView(),
    );
  }
}

class _ProductCreateView extends StatelessWidget {
  const _ProductCreateView();

  Future<void> _create(BuildContext context, ProductInput input, ProductPhoto? photo) async {
    final l10n = AppLocalizations.of(context);
    final controller = context.read<ProductEditorController>();
    final outcome = await controller.create(input, photo);
    if (!context.mounted) return;
    final failure = controller.saveFailure;
    if (outcome == SaveOutcome.failed) {
      // Erro por campo (ex.: nome repetido) também marca o campo no formulário; a mensagem vem aqui
      if (failure != null) showAppToast(context, failureMessage(l10n, failure), tone: ToastTone.error);
      return;
    }
    outcome == SaveOutcome.saved
        ? showAppToast(context, l10n.productCreated)
        : showAppToast(context, l10n.productPhotoUploadFailed, tone: ToastTone.error);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<ProductEditorController>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(title: l10n.productNewTitle, onBack: () => context.pop(), buttonBackground: context.colors.surface),
            Expanded(
              child: ProductForm(
                initialValue: null,
                submitLabel: l10n.productSave,
                isSaving: controller.isSaving,
                serverFailure: controller.saveFailure,
                onSubmit: (input, photo) => _create(context, input, photo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
