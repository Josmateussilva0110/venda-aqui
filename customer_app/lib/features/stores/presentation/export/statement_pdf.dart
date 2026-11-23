import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/statement_entry.dart';
import '../../domain/store.dart';
import '../statement_labels.dart';

/// Medidas do PDF, em pontos (1/72 pol.). O PDF é sempre claro, independente do tema do app.
abstract final class _PdfStyle {
  static const regularFont = 'assets/fonts/Manrope-Regular.ttf';
  static const boldFont = 'assets/fonts/Manrope-Bold.ttf';

  static const margin = 32.0;
  static const gap = 8.0;
  static const cellPadding = 6.0;
  static const titleSize = 16.0;
  static const bodySize = 10.0;
  static const smallSize = 8.0;

  /// Larguras relativas das colunas: data, descrição, valor.
  static const dateColumn = 2.0;
  static const descriptionColumn = 5.0;
  static const amountColumn = 2.0;

  static const colors = AppColors.light;
  static PdfColor color(Color color) => PdfColor.fromInt(color.toARGB32());
}

/// Monta o extrato da loja em PDF: resumo do saldo e todas as compras e pagamentos.
abstract final class StatementPdf {
  static Future<Uint8List> build({
    required Store store,
    required List<StatementEntry> entries,
    required AppLocalizations l10n,
    required DateTime generatedAt,
  }) async {
    // A fonte do app tem os acentos e símbolos (×, −) que a fonte padrão do PDF não tem
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load(_PdfStyle.regularFont)),
      bold: pw.Font.ttf(await rootBundle.load(_PdfStyle.boldFont)),
    );
    final title = l10n.statementPdfTitle(store.merchantName);
    final document = pw.Document(title: title, creator: l10n.appTitle);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(_PdfStyle.margin),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: _text(l10n.statementPdfPage('${context.pageNumber}', '${context.pagesCount}'), size: _PdfStyle.smallSize, muted: true),
        ),
        build: (_) => [
          _summary(store: store, l10n: l10n, title: title, generatedAt: generatedAt),
          pw.SizedBox(height: _PdfStyle.gap * 2),
          if (entries.isEmpty) _text(l10n.statementEmpty) else _entriesTable(entries, l10n),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _summary({required Store store, required AppLocalizations l10n, required String title, required DateTime generatedAt}) {
    final dueDate = store.creditDueDate;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _text(title, size: _PdfStyle.titleSize, bold: true),
        pw.SizedBox(height: _PdfStyle.gap / 2),
        _text(l10n.statementPdfCustomer(store.customerName)),
        _text(l10n.statementPdfGeneratedAt(AppDateFormat.momentIn(l10n.localeName, generatedAt)), size: _PdfStyle.smallSize, muted: true),
        pw.SizedBox(height: _PdfStyle.gap),
        if (store.owes) ...[
          _text('${l10n.storeOwes}: ${MoneyFormat.format(store.balanceCents)}', bold: true, color: _PdfStyle.colors.dangerStrong),
          if (dueDate != null) _text(l10n.storeDueOn(AppDateFormat.dayIn(l10n.localeName, dueDate))),
        ] else
          _text(l10n.storeNothingOwed, bold: true, color: _PdfStyle.colors.success),
      ],
    );
  }

  static pw.Widget _entriesTable(List<StatementEntry> entries, AppLocalizations l10n) {
    final border = pw.BorderSide(color: _PdfStyle.color(_PdfStyle.colors.divider));
    return pw.Table(
      border: pw.TableBorder(horizontalInside: border, bottom: border),
      columnWidths: const {
        0: pw.FlexColumnWidth(_PdfStyle.dateColumn),
        1: pw.FlexColumnWidth(_PdfStyle.descriptionColumn),
        2: pw.FlexColumnWidth(_PdfStyle.amountColumn),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _PdfStyle.color(_PdfStyle.colors.surfaceMuted)),
          children: [
            _cell(_text(l10n.statementPdfDate, bold: true)),
            _cell(_text(l10n.statementPdfDescription, bold: true)),
            _cell(_text(l10n.statementPdfAmount, bold: true), alignEnd: true),
          ],
        ),
        for (final entry in entries) _entryRow(entry, l10n),
      ],
    );
  }

  static pw.TableRow _entryRow(StatementEntry entry, AppLocalizations l10n) {
    final isPayment = entry.kind == StatementKind.payment;
    final amount = MoneyFormat.format(entry.amountCents);
    return pw.TableRow(
      children: [
        _cell(_text(AppDateFormat.momentIn(l10n.localeName, entry.createdAt))),
        _cell(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _text(entry.title(l10n), bold: true),
              for (final item in entry.items)
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(child: _text(item.line(l10n), size: _PdfStyle.smallSize, muted: true)),
                    pw.SizedBox(width: _PdfStyle.gap),
                    _text(MoneyFormat.format(item.subtotalCents), size: _PdfStyle.smallSize, muted: true),
                  ],
                ),
            ],
          ),
        ),
        _cell(_text(isPayment ? '− $amount' : amount, bold: true, color: isPayment ? _PdfStyle.colors.success : null), alignEnd: true),
      ],
    );
  }

  static pw.Widget _cell(pw.Widget child, {bool alignEnd = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(_PdfStyle.cellPadding),
      child: pw.Align(alignment: alignEnd ? pw.Alignment.topRight : pw.Alignment.topLeft, child: child),
    );
  }

  static pw.Widget _text(String text, {double size = _PdfStyle.bodySize, bool bold = false, bool muted = false, Color? color}) {
    const colors = _PdfStyle.colors;
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: _PdfStyle.color(color ?? (muted ? colors.muted : colors.ink)),
      ),
    );
  }
}
