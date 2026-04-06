import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _load();
  }

  static const _key = 'mindcare_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final name = p.getString(_key);
    if (name == 'dark') {
      _mode = ThemeMode.dark;
    } else if (name == 'light') {
      _mode = ThemeMode.light;
    } else {
      _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode next) async {
    _mode = next;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _key,
      next == ThemeMode.dark
          ? 'dark'
          : next == ThemeMode.light
              ? 'light'
              : 'system',
    );
  }

  Future<void> toggleDarkLight() async {
    if (_mode == ThemeMode.dark) {
      await setMode(ThemeMode.light);
    } else {
      await setMode(ThemeMode.dark);
    }
  }
}
