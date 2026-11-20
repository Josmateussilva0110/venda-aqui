import 'package:flutter_test/flutter_test.dart';
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
}
