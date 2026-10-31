import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Monta instâncias de Dio com a mesma base (URL, timeouts, JSON), sem interceptors.
abstract final class HttpClientFactory {
  static Dio create(AppConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl.toString(),
        connectTimeout: config.httpTimeout,
        receiveTimeout: config.httpTimeout,
        sendTimeout: config.httpTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
  }
}
