import 'package:flutter/foundation.dart';

/// Se a última consulta precisou da cópia local por falta de internet. A faixa de aviso escuta isto.
class OfflineStatus extends ChangeNotifier {
  bool _isOffline = false;
  DateTime? _savedAt;

  bool get isOffline => _isOffline;

  /// Quando a cópia local foi atualizada pela última vez; nula se nunca sincronizou.
  DateTime? get savedAt => _savedAt;

  void markOffline(DateTime? savedAt) {
    if (_isOffline && _savedAt == savedAt) return;
    _isOffline = true;
    _savedAt = savedAt;
    notifyListeners();
  }

  void markOnline() {
    if (!_isOffline) return;
    _isOffline = false;
    notifyListeners();
  }
}
