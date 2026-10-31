import 'package:flutter/foundation.dart';

/// Ignora notificações depois do `dispose`: uma requisição pode terminar com a tela já fechada,
/// e notificar um controller descartado lança erro.
mixin DisposeAwareNotifier on ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
