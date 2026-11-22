import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/store.dart';
import '../controllers/statement_controller.dart';
import '../export/statement_pdf.dart';

/// Gera o PDF do extrato inteiro e abre o compartilhar do Android (WhatsApp, Drive, salvar...).
class StatementExportButton extends StatelessWidget {
  const StatementExportButton({super.key, required this.store});

  final Store store;

  Future<void> _export(BuildContext context, StatementController controller) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await controller.export((entries) async {
        final now = DateTime.now();
        final bytes = await StatementPdf.build(store: store, entries: entries, l10n: l10n, generatedAt: now);
        await Printing.sharePdf(bytes: bytes, filename: l10n.statementPdfFileName(AppDateFormat.fileDate(now)));
      });
    } on AppFailure catch (failure) {
      messenger.showAppToast(failureMessage(l10n, failure), tone: ToastTone.error);
    } on Exception {
      // Falha ao montar o arquivo ou ao abrir o compartilhar: detalhe técnico não ajuda o cliente
      messenger.showAppToast(l10n.statementExportFailed, tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<StatementController>();
    final canExport = !controller.isLoadingFirst && controller.firstPageFailure == null && controller.items.isNotEmpty;

    if (controller.isExporting) {
      final iconSize = context.sizes.icon;
      return Padding(
        padding: EdgeInsets.all(context.spacing.md),
        child: SizedBox.square(
          dimension: iconSize,
          child: Semantics(label: l10n.statementExport, child: const CircularProgressIndicator.adaptive()),
        ),
      );
    }
    return IconButton(
      tooltip: l10n.statementExport,
      onPressed: canExport ? () => _export(context, controller) : null,
      icon: const Icon(Icons.picture_as_pdf_outlined),
    );
  }
}
