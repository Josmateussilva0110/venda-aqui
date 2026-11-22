import 'statement_entry.dart';
import 'store.dart';

abstract interface class StoresRepository {
  Future<List<Store>> listStores();

  Future<StatementPage> statement(String storeId, {required int offset, required int limit});
}
