import '../../../core/network/api_codes.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/request_data.dart';
import '../domain/invite_info.dart';
import '../domain/login_method.dart';
import 'auth_dtos.dart';

/// Rotas de acesso do portal. Tudo passa por [requestData]; falhas viram [AppFailure].
class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  Future<SessionTokens> login({
    required LoginMethod method,
    required String identifierDigits,
    required String pin,
    required String deviceId,
  }) {
    return _session(ApiPaths.login, {'method': method.apiValue, method.apiValue: identifierDigits, 'pin': pin, 'deviceId': deviceId});
  }

  Future<InviteInfo> inspectInvite(String token) async {
    final response = await requestData<InviteInfo>(
      endpoint: ApiPaths.inviteInspect,
      method: 'POST',
      data: {'token': token},
      withAuth: false,
      parse: (json) => InviteInfoDto.fromJson(jsonMap(json)),
    );
    return response.requireData();
  }

  Future<SessionTokens> acceptInvite({required String token, String? currentPin, String? newPin, required String deviceId}) {
    return _session(ApiPaths.inviteAccept, {
      'token': token,
      'deviceId': deviceId,
      'currentPin': ?currentPin,
      if (newPin != null) ...{'newPin': newPin, 'newPinConfirmation': newPin},
    });
  }

  Future<void> logout() async {
    final response = await requestData<void>(endpoint: ApiPaths.logout, method: 'POST');
    response.ensureSuccess();
  }

  Future<SessionTokens> _session(String endpoint, Map<String, Object> body) async {
    final response = await requestData<SessionTokens>(
      endpoint: endpoint,
      method: 'POST',
      data: body,
      withAuth: false,
      parse: (json) => SessionTokensDto.fromJson(jsonMap(json)),
    );
    return response.requireData();
  }
}
