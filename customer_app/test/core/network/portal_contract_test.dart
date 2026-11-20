import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui_cliente/features/auth/data/auth_remote_data_source.dart';
import 'package:vendaqui_cliente/features/auth/domain/login_method.dart';
import 'package:vendaqui_cliente/features/stores/data/stores_remote_data_source.dart';
import 'package:vendaqui_cliente/features/stores/domain/statement_entry.dart';

import '../../support/scripted_api.dart';

/// Formato das respostas e dos corpos como o backend (rotas /api/portal) usa: se um lado mudar o nome
/// de um campo, o app mostraria erro genérico sem nenhum aviso de compilação.
void main() {
  late ScriptedApi api;

  setUp(() => api = ScriptedApi());

  test('login pelo CPF manda o método e o campo com o nome dele', () async {
    api.responses.add((
      200,
      {
        'success': true,
        'message': 'ok',
        'data': {'accessToken': 'a', 'refreshToken': 'r'},
      },
    ));

    await const AuthRemoteDataSource().login(method: LoginMethod.cpf, identifierDigits: '52998224725', pin: '1357', deviceId: 'device-1');

    expect(api.requests.single.path, '/portal/auth/login');
    expect(api.bodyOf(0), {'method': 'cpf', 'cpf': '52998224725', 'pin': '1357', 'deviceId': 'device-1'});
  });

  test('aceitar com PIN atual não manda PIN novo, e vice-versa', () async {
    final session = {
      'success': true,
      'message': 'ok',
      'data': {'accessToken': 'a', 'refreshToken': 'r'},
    };
    api.responses.addAll([(200, session), (200, session)]);
    const remote = AuthRemoteDataSource();

    await remote.acceptInvite(token: 't', currentPin: '2468', deviceId: 'd');
    await remote.acceptInvite(token: 't', newPin: '1357', deviceId: 'd');

    expect(api.bodyOf(0), {'token': 't', 'deviceId': 'd', 'currentPin': '2468'});
    expect(api.bodyOf(1), {'token': 't', 'deviceId': 'd', 'newPin': '1357', 'newPinConfirmation': '1357'});
  });

  test('lê lojas e extrato no formato do backend', () async {
    api.responses.addAll([
      (
        200,
        {
          'success': true,
          'message': 'Lojas carregadas.',
          'data': [
            {'id': 'c1', 'merchantName': 'Loja A', 'customerName': 'Maria', 'balanceCents': 1500, 'creditDueDate': '2026-12-05'},
          ],
        },
      ),
      (
        200,
        {
          'success': true,
          'message': 'Movimentações carregadas.',
          'data': {
            'items': [
              {'kind': 'payment', 'id': 'p1', 'amountCents': 500, 'paymentMethod': 'pix', 'createdAt': '2026-11-10T21:00:00.000Z'},
              {'kind': 'sale', 'id': 's1', 'amountCents': 2000, 'paymentMethod': 'credit', 'createdAt': '2026-11-02T12:00:00.000Z'},
            ],
            'total': 3,
            'limit': 2,
            'offset': 0,
          },
        },
      ),
    ]);
    const remote = StoresRemoteDataSource();

    final stores = await remote.listStores();
    final page = await remote.statement('c1', offset: 0, limit: 2);

    expect(stores.single.balanceCents, 1500);
    expect(stores.single.creditDueDate, DateTime(2026, 12, 5));
    expect(api.requests.last.queryParameters, {'offset': 0, 'limit': 2});
    expect(page.items.map((entry) => (entry.kind, entry.paymentMethod)), [
      (StatementKind.payment, PaymentMethod.pix),
      (StatementKind.purchase, PaymentMethod.credit),
    ]);
    expect(page.hasMore, isTrue);
  });
}
