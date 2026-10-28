import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
      create: (context) => ProductEditorController(context.read<ProductsRepository>()),
      child: const _ProductCreateView(),
    );
  }
}

class _ProductCreateView extends StatelessWidget {
  const _ProductCreateView();

  Future<void> _create(BuildContext context, ProductInput input, ProductPhoto? photo) async {
    final l10n = AppLocalizations.of(context);
    final outcome = await context.read<ProductEditorController>().create(input, photo);
    if (!context.mounted || outcome == SaveOutcome.failed) return;
    showAppToast(context, outcome == SaveOutcome.saved ? l10n.productCreated : l10n.productPhotoUploadFailed);
    context.pop(true);
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
