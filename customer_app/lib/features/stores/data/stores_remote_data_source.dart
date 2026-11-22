import '../../../core/network/api_codes.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/request_data.dart';
import '../domain/statement_entry.dart';
import '../domain/store.dart';
import 'stores_dtos.dart';

class StoresRemoteDataSource {
  const StoresRemoteDataSource();

  Future<List<Store>> listStores() async {
    final response = await requestData<List<Store>>(
      endpoint: ApiPaths.stores,
      parse: (json) => (json! as List<Object?>).whereType<Map<String, dynamic>>().map(StoreDto.fromJson).toList(growable: false),
    );
    return response.requireData();
  }

  Future<StatementPage> statement(String storeId, {required int offset, required int limit}) async {
    final response = await requestData<StatementPage>(
      endpoint: ApiPaths.storeStatement(storeId),
      params: {'offset': offset, 'limit': limit},
      parse: (json) => StatementDto.fromJson(jsonMap(json)),
    );
    return response.requireData();
  }
}
