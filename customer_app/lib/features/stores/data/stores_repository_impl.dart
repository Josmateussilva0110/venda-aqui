import '../domain/statement_entry.dart';
import '../domain/store.dart';
import '../domain/stores_repository.dart';
import 'stores_remote_data_source.dart';

class StoresRepositoryImpl implements StoresRepository {
  const StoresRepositoryImpl(this._remote);

  final StoresRemoteDataSource _remote;

  @override
  Future<List<Store>> listStores() => _remote.listStores();

  @override
  Future<StatementPage> statement(String storeId, {required int offset, required int limit}) {
    return _remote.statement(storeId, offset: offset, limit: limit);
  }
}
