/// Por onde o cliente entra. Vai explícito para a API: um celular com DDD também tem 11 dígitos.
enum LoginMethod {
  phone('phone'),
  cpf('cpf');

  const LoginMethod(this.apiValue);

  final String apiValue;
}
