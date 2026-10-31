import '../../../core/network/json_reader.dart';
import '../domain/merchant.dart';

abstract final class MerchantDto {
  static Merchant fromJson(Map<String, dynamic> json) {
    return Merchant(id: json.requireString('id'), name: json.requireString('name'), phone: json.requireString('phone'));
  }
}

/// Resposta de cadastro, login e recuperação de PIN.
class SessionDto {
  const SessionDto({required this.merchant, required this.accessToken, required this.refreshToken});

  final Merchant merchant;
  final String accessToken;
  final String refreshToken;

  factory SessionDto.fromJson(Map<String, dynamic> json) {
    return SessionDto(
      merchant: MerchantDto.fromJson(json.requireMap('merchant')),
      accessToken: json.requireString('accessToken'),
      refreshToken: json.requireString('refreshToken'),
    );
  }
}
