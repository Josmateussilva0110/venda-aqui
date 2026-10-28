/// Converte o `data` da resposta em mapa para os `parse` de [requestData].
/// Tipo errado lança, e [ApiResponse.fromJson] transforma isso em resposta inválida.
Map<String, dynamic> jsonMap(Object? json) => json! as Map<String, dynamic>;
