import '../../../core/network/api_codes.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../domain/merchant.dart';
import 'auth_dtos.dart';

/// Rotas de autenticação. Tudo passa por [requestData]; falhas viram [AppFailure].
class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  Future<bool> checkPhone(String phone) async {
    final response = await requestData<bool>(
      endpoint: ApiPaths.phoneCheck,
      method: 'POST',
      data: {'phone': phone},
      withAuth: false,
      parse: (json) => jsonMap(json).optionalBool('available'),
    );
    return response.requireData();
  }

  Future<SessionDto> register({required String name, required String phone, required String pin, required String deviceId}) {
    return _session(ApiPaths.register, {'name': name, 'phone': phone, 'pin': pin, 'pinConfirmation': pin, 'deviceId': deviceId});
  }

  Future<SessionDto> login({required String phone, required String pin, required String deviceId}) {
    return _session(ApiPaths.login, {'phone': phone, 'pin': pin, 'deviceId': deviceId});
  }

  Future<void> requestPinRecovery(String phone) async {
    final response = await requestData<void>(
      endpoint: ApiPaths.pinRecoveryRequest,
      method: 'POST',
      data: {'phone': phone},
      withAuth: false,
    );
    response.ensureSuccess();
  }

  Future<SessionDto> confirmPinRecovery({required String phone, required String code, required String pin, required String deviceId}) {
    return _session(ApiPaths.pinRecoveryConfirm, {'phone': phone, 'code': code, 'pin': pin, 'pinConfirmation': pin, 'deviceId': deviceId});
  }

  Future<Merchant> me() async {
    final response = await requestData<Merchant>(endpoint: ApiPaths.me, parse: (json) => MerchantDto.fromJson(jsonMap(json)));
    return response.requireData();
  }

  Future<void> logout() async {
    final response = await requestData<void>(endpoint: ApiPaths.logout, method: 'POST');
    response.ensureSuccess();
  }

  Future<SessionDto> _session(String endpoint, Map<String, Object> body) async {
    final response = await requestData<SessionDto>(
      endpoint: endpoint,
      method: 'POST',
      data: body,
      withAuth: false,
      parse: (json) => SessionDto.fromJson(jsonMap(json)),
    );
    return response.requireData();
  }
}
