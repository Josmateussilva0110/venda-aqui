import '../../../core/network/json_reader.dart';
import '../domain/invite_info.dart';

typedef SessionTokens = ({String accessToken, String refreshToken});

abstract final class SessionTokensDto {
  static SessionTokens fromJson(Map<String, dynamic> json) {
    return (accessToken: json.requireString('accessToken'), refreshToken: json.requireString('refreshToken'));
  }
}

abstract final class InviteInfoDto {
  static InviteInfo fromJson(Map<String, dynamic> json) {
    return InviteInfo(
      merchantName: json.requireString('merchantName'),
      phoneEnding: json.requireString('phoneEnding'),
      hasAccount: json.optionalBool('hasAccount'),
    );
  }
}
