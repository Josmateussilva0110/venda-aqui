import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/offline/local_database.dart';
import 'package:vendaqui/core/offline/offline_reader.dart';
import 'package:vendaqui/core/offline/offline_status.dart';
import 'package:vendaqui/core/offline/offline_store.dart';
import 'package:vendaqui/core/offline/offline_writer.dart';
import 'package:vendaqui/core/offline/outbox.dart';
import 'package:vendaqui/features/customers/data/customers_repository_impl.dart';
import 'package:vendaqui/features/customers/data/pending_payment_sender.dart';
import 'package:vendaqui/features/customers/domain/customer.dart';

import '../../support/fakes.dart';
import '../../support/scripted_api.dart';

void main() {
  test('pagamento recebido sem internet fica na fila, baixa a dívida da cópia e sobe com a hora do recebimento', () async {
    final api = ScriptedApi();
    final db = memoryDatabase();
    final store = OfflineStore(db);
    final outbox = Outbox(db, store)..register(PendingPaymentSender.kind, const PendingPaymentSender().send);
    await store.saveOwner((id: 'm1', name: 'Mercearia', phone: '+5586999990000'));
    await store.upsertCustomers([
      LocalCustomersCompanion.insert(id: 'c1', name: 'Ana', searchKey: 'ana', phone: '+5586988880000', balanceCents: 1000),
    ]);
    final paidAt = DateTime(2026, 11, 15, 10, 30);
    final reader = OfflineReader(store, OfflineStatus(), clock: () => paidAt);
    final repository = CustomersRepositoryImpl(reader, OfflineWriter(reader, outbox, clock: () => paidAt, newId: () => 'pay-1'));

    final receipt = await repository.registerPayment('c1', amountCents: 400, method: SettlementMethod.pix);

    expect(receipt.state, SyncState.pending);
    expect(receipt.balanceCents, isNull, reason: 'o saldo de verdade só o servidor sabe');
    expect((await store.customer('c1'))?.balanceCents, 600);
    expect(outbox.pendingCount, 1);

    api.responses.add((
      201,
      {
        'success': true,
        'message': 'Pagamento registrado.',
        'data': {'id': 'p1', 'balanceCents': 600},
      },
    ));
    expect(await outbox.flush(), isTrue);

    final sent = api.requests.last;
    expect(sent.path, '/customers/c1/payments');
    // O mesmo id da tentativa online: se aquela tivesse chegado, o servidor não baixaria a dívida duas vezes
    expect(api.bodyOf(0)['clientId'], 'pay-1');
    expect(api.bodyOf(1), {'amountCents': 400, 'paymentMethod': 'pix', 'clientId': 'pay-1', 'paidAt': paidAt.toUtc().toIso8601String()});
  });
}
