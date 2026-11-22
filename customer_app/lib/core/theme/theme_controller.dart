import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onde a escolha de tema fica guardada. Não é dado sensível: preferências comuns bastam.
abstract interface class ThemePreferenceStore {
  Future<ThemeMode?> read();

  Future<void> write(ThemeMode mode);
}

class SharedPreferencesThemeStore implements ThemePreferenceStore {
  static const _key = 'theme_mode';

  @override
  Future<ThemeMode?> read() async {
    final value = (await SharedPreferences.getInstance()).getString(_key);
    return ThemeMode.values.where((mode) => mode.name == value).firstOrNull;
  }

  @override
  Future<void> write(ThemeMode mode) async {
    await (await SharedPreferences.getInstance()).setString(_key, mode.name);
  }
}

/// Tema escolhido pelo usuário (claro, escuro ou igual ao sistema). Único ponto de troca do tema do app.
class ThemeController extends ChangeNotifier {
  ThemeController(this._store, {ThemeMode initial = ThemeMode.system}) : _mode = initial;

  final ThemePreferenceStore _store;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  /// Lê a escolha salva antes de abrir o app, para a primeira tela já vir no tema certo.
  static Future<ThemeController> load(ThemePreferenceStore store) async {
    ThemeMode? saved;
    try {
      saved = await store.read();
    } on Exception {
      // Preferência ilegível não pode impedir o app de abrir: segue o tema do sistema
      saved = null;
    }
    return ThemeController(store, initial: saved ?? ThemeMode.system);
  }

  Future<void> select(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _store.write(mode);
  }
}
