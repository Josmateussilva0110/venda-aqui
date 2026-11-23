import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendaqui_cliente/features/stores/presentation/export/statement_pdf.dart';
import 'package:vendaqui_cliente/l10n/app_localizations_pt.dart';
import 'package:vendaqui_cliente/features/stores/domain/statement_entry.dart';
import 'package:vendaqui_cliente/features/stores/presentation/controllers/statement_controller.dart';

import '../../support/fakes.dart';

StatementEntry _entry(int index) => StatementEntry(
  id: 'e$index',
  kind: StatementKind.purchase,
  amountCents: 100,
  paymentMethod: PaymentMethod.credit,
  createdAt: DateTime(2026, 11, 1).subtract(Duration(minutes: index)),
);

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  // Regressão: a paginação é por posição, e uma venda feita na loja enquanto o cliente rola empurrava a lista,
  // repetindo o último lançamento da página anterior
  test('venda nova entre uma página e outra não repete lançamento', () async {
    final entries = List.generate(StatementController.pageSize + 5, _entry);
    final repository = FakeStoresRepository(entries: entries);
    final controller = StatementController(repository, storeId: testStore.id);
    await controller.loadFirst();

    entries.insert(0, _entry(-1));
    await controller.loadMore();

    final ids = controller.items.map((entry) => entry.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(ids.length, StatementController.pageSize + 5);
  });

  // O PDF precisa trazer o histórico inteiro, não só a primeira página nem o que apareceu na tela
  test('exportar busca todas as páginas sem repetir e gera o PDF', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final entries = List.generate(StatementController.exportPageSize * 2 + 7, _entry);
    final repository = FakeStoresRepository(entries: entries);
    final controller = StatementController(repository, storeId: testStore.id);

    List<StatementEntry>? exported;
    var injected = false;
    await controller.export((received) async {
      exported = received;
    });
    expect(exported!.length, entries.length);

    // Venda nova durante a exportação: empurra a lista e não pode duplicar nem perder lançamentos
    final shifting = _ShiftingRepository(
      entries,
      onSecondPage: () {
        if (injected) return;
        injected = true;
        entries.insert(0, _entry(-1));
      },
    );
    await StatementController(shifting, storeId: testStore.id).export((received) async => exported = received);
    final ids = exported!.map((entry) => entry.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(ids.toSet().containsAll(entries.skip(1).map((entry) => entry.id)), isTrue);

    final bytes = await StatementPdf.build(
      store: testStore,
      entries: exported!,
      l10n: AppLocalizationsPt(),
      generatedAt: DateTime(2026, 11, 20),
    );
    expect(bytes, isNotEmpty);
    expect(controller.isExporting, isFalse);
  });
}

/// Repositório que roda [onSecondPage] antes de responder a segunda página.
class _ShiftingRepository extends FakeStoresRepository {
  _ShiftingRepository(List<StatementEntry> entries, {required this.onSecondPage}) : super(entries: entries);

  final void Function() onSecondPage;

  @override
  Future<StatementPage> statement(String storeId, {required int offset, required int limit}) {
    if (offset > 0) onSecondPage();
    return super.statement(storeId, offset: offset, limit: limit);
  }
}
