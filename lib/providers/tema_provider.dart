import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  bool _cargado = false;

  ThemeMode get mode => _mode;
  bool get cargado => _cargado;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('themeMode')) {
      // ✅ Primera vez: forzamos claro por defecto (o pon 'dark' si prefieres)
      await prefs.setString('themeMode', 'light');
    }
    final themeStr = prefs.getString('themeMode')!;
    _mode = ThemeMode.values.firstWhere((e) => e.name == themeStr);
    _cargado = true;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _saveMode(mode);
  }

  Future<void> toggle() async {
    final newMode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _saveMode(newMode);
  }

  Future<void> _saveMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }
}
