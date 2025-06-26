import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void toggleTheme(bool isDark) {
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
