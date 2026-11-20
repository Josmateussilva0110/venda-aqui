import 'package:vendaqui_cliente/core/network/app_failure.dart';
import 'package:vendaqui_cliente/features/auth/domain/auth_repository.dart';
import 'package:vendaqui_cliente/features/auth/domain/invite_info.dart';
import 'package:vendaqui_cliente/features/auth/domain/login_method.dart';
import 'package:vendaqui_cliente/features/stores/domain/statement_entry.dart';
import 'package:vendaqui_cliente/features/stores/domain/store.dart';
import 'package:vendaqui_cliente/features/stores/domain/stores_repository.dart';

/// Nomes longos de propósito: é o pior caso para o layout.
const testStore = Store(
  id: '10000000-0000-0000-0000-00000000000a',
  merchantName: 'Mercadinho e Hortifruti Nossa Senhora Aparecida',
  customerName: 'Maria Aparecida dos Santos Oliveira',
  balanceCents: 123456789,
  creditDueDate: null,
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.signedIn = false, this.inviteInfo, this.acceptFailure});

  bool signedIn;
  InviteInfo? inviteInfo;
  AppFailure? acceptFailure;
  final acceptCalls = <({String token, String? currentPin, String? newPin})>[];

  @override
  Future<bool> restoreSession() async => signedIn;

  @override
  Future<void> login({required LoginMethod method, required String identifierDigits, required String pin}) async {
    signedIn = true;
  }

  @override
  Future<InviteInfo> inspectInvite(String token) async {
    final info = inviteInfo;
    if (info == null) throw const RequestFailure(statusCode: 410, message: 'Link inválido', code: 'PORTAL_INVITE_INVALID');
    return info;
  }

  @override
  Future<void> acceptInvite({required String token, String? currentPin, String? newPin}) async {
    acceptCalls.add((token: token, currentPin: currentPin, newPin: newPin));
    final failure = acceptFailure;
    if (failure != null) throw failure;
    signedIn = true;
  }

  @override
  Future<void> logout() async => signedIn = false;
}

class FakeStoresRepository implements StoresRepository {
  FakeStoresRepository({this.stores = const [testStore], List<StatementEntry>? entries}) : entries = entries ?? _defaultEntries;

  final List<Store> stores;
  final List<StatementEntry> entries;

  static final _defaultEntries = [
    StatementEntry(
      id: 's1',
      kind: StatementKind.purchase,
      amountCents: 1234567,
      paymentMethod: PaymentMethod.credit,
      createdAt: DateTime(2026, 11, 2, 9),
    ),
    StatementEntry(
      id: 'p1',
      kind: StatementKind.payment,
      amountCents: 50000,
      paymentMethod: PaymentMethod.card,
      createdAt: DateTime(2026, 11, 10, 18),
    ),
  ];

  @override
  Future<List<Store>> listStores() async => stores;

  @override
  Future<StatementPage> statement(String storeId, {required int offset, required int limit}) async {
    final page = entries.skip(offset).take(limit).toList();
    return StatementPage(items: page, total: entries.length, offset: offset);
  }
}
