import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/offline/offline_reader.dart';
import 'package:vendaqui/core/offline/offline_status.dart';
import 'package:vendaqui/core/offline/offline_store.dart';
import 'package:vendaqui/core/offline/offline_writer.dart';
import 'package:vendaqui/core/offline/outbox.dart';
import 'package:vendaqui/core/network/app_failure.dart';
import 'package:vendaqui/features/customers/data/customers_repository_impl.dart';

import '../../support/fakes.dart';
import '../../support/scripted_api.dart';

/// Contrato com POST /customers/:id/portal-invite: o link é o único jeito de o cliente ganhar acesso ao app dele.
void main() {
  late ScriptedApi api;
  late CustomersRepositoryImpl repository;

  setUp(() {
    api = ScriptedApi();
    final db = memoryDatabase();
    final store = OfflineStore(db);
    final reader = OfflineReader(store, OfflineStatus());
    repository = CustomersRepositoryImpl(reader, OfflineWriter(reader, Outbox(db, store)));
  });

  test('gera o link pelo servidor e lê url e validade', () async {
    api.responses.add((
      201,
      {
        'success': true,
        'message': 'Link de acesso gerado.',
        'data': {'url': 'vendaqui-cliente://convite?token=abc', 'expiresAt': '2026-11-21T13:00:00.000Z'},
      },
    ));

    final invite = await repository.createPortalInvite('c1');

    expect(api.requests.single.path, '/customers/c1/portal-invite');
    expect(api.requests.single.method, 'POST');
    expect(invite.url, 'vendaqui-cliente://convite?token=abc');
    expect(invite.expiresAt, DateTime.utc(2026, 11, 21, 13).toLocal());
  });

  // O link nasce no servidor (só o hash fica lá): sem internet não há link, nem guardado na fila
  test('sem internet falha em vez de ir para a fila', () async {
    api.responses.add(null);
    await expectLater(repository.createPortalInvite('c1'), throwsA(isA<NetworkFailure>()));
  });
}
