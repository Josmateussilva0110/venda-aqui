import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/offline/offline_reader.dart';
import 'package:vendaqui/core/offline/offline_status.dart';
import 'package:vendaqui/core/offline/offline_store.dart';
import 'package:vendaqui/core/offline/offline_writer.dart';
import 'package:vendaqui/core/offline/outbox.dart';
import 'package:vendaqui/features/customers/data/customers_repository_impl.dart';
import 'package:vendaqui/features/customers/data/pending_customer_sender.dart';
import 'package:vendaqui/features/customers/domain/customer.dart';
import 'package:vendaqui/features/sales/data/catalog_remote_data_source.dart';
import 'package:vendaqui/features/sales/data/pending_sale_sender.dart';
import 'package:vendaqui/features/sales/data/sales_remote_data_source.dart';
import 'package:vendaqui/features/sales/data/sales_repository_impl.dart';
import 'package:vendaqui/features/sales/domain/sale.dart';

import '../../support/fakes.dart';
import '../../support/scripted_api.dart';

void main() {
  test('cliente cadastrado sem internet recebe venda fiado offline, e o cadastro sobe antes da venda', () async {
    final api = ScriptedApi();
    final db = memoryDatabase();
    final store = OfflineStore(db);
    final outbox = Outbox(db, store)
      ..register(PendingCustomerSender.kind, const PendingCustomerSender().send)
      ..register(PendingSaleSender.kind, const PendingSaleSender().send);
    await store.saveOwner((id: 'm1', name: 'Mercearia', phone: '+5586999990000'));
    final ids = ['cliente-novo', 'venda-1'];
    final reader = OfflineReader(store, OfflineStatus());
    final writer = OfflineWriter(reader, outbox, newId: () => ids.removeAt(0));
    final customers = CustomersRepositoryImpl(reader, writer);
    final sales = SalesRepositoryImpl(const CatalogRemoteDataSource(), const SalesRemoteDataSource(), reader, writer, outbox);

    final customer = await customers.create(const CustomerInput(name: '  Ana Souza ', phone: '(86) 98888-0000'));
    expect(customer.id, 'cliente-novo');
    expect((await store.customer('cliente-novo'))?.name, 'Ana Souza', reason: 'aparece na lista sem internet');

    await sales.register(
      SaleInput(
        items: const [SaleItem(productId: 'p1', name: 'Arroz', unitPriceCents: 500, quantity: 2, soldByWeight: false)],
        method: PaymentMethod.credit,
        customer: SaleCustomer(id: customer.id, name: customer.name),
      ),
    );
    expect((await store.customer('cliente-novo'))?.balanceCents, 1000);
    expect(outbox.pendingCount, 2);

    api.responses.addAll([
      (
        201,
        {
          'success': true,
          'message': 'Cliente cadastrado com sucesso.',
          'data': {'id': 'cliente-novo'},
        },
      ),
      (
        201,
        {
          'success': true,
          'message': 'Venda registrada com sucesso.',
          'data': {'id': 's1', 'totalCents': 1000, 'stockShortfalls': [], 'replayed': false},
        },
      ),
    ]);
    expect(await outbox.flush(), isTrue);
    final sent = api.requests.skip(1).toList();
    expect(sent.map((request) => request.path), ['/customers', '/sales']);
    expect((sent[0].data as Map)['clientId'], 'cliente-novo');
    expect((sent[1].data as Map)['customerId'], 'cliente-novo', reason: 'a venda aponta para o id que o cadastro criou');
  });
}
