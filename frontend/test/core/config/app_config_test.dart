import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/config/app_config.dart';

// Limite de segurança: HTTP (sem criptografia) só pode valer para o servidor na rede local
void main() {
  test('aceita HTTPS em qualquer endereço e HTTP só na rede local', () {
    expect(AppConfig.parseApiUrl('https://api.vendaqui.com.br/api').host, 'api.vendaqui.com.br');
    for (final local in [
      'http://192.168.1.15:8080/api',
      'http://10.0.2.2:8080/api',
      'http://172.20.0.5/api',
      'http://localhost:8080/api',
    ]) {
      expect(AppConfig.parseApiUrl(local).scheme, 'http', reason: local);
    }
  });

  test('recusa HTTP em endereço público e URL malformada', () {
    for (final invalid in [
      'http://api.vendaqui.com.br/api',
      'http://8.8.8.8/api',
      'http://172.32.0.1/api',
      'ftp://192.168.1.15',
      'api/sem-esquema',
      '',
    ]) {
      expect(() => AppConfig.parseApiUrl(invalid), throwsStateError, reason: invalid);
    }
  });
}
