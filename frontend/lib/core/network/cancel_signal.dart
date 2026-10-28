import 'package:dio/dio.dart';

/// Permite cancelar uma requisição em andamento (ex.: busca substituída por outra).
class CancelSignal {
  final CancelToken token = CancelToken();

  bool get isCancelled => token.isCancelled;

  void cancel() {
    if (!token.isCancelled) token.cancel();
  }
}
