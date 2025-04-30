// lib/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  bool _isDarkMode = true;
  final String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  ThemeService() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? true;
      notifyListeners();
    } catch (e) {
      _isDarkMode = true;
    }
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      // opcional: loguear el error
      debugPrint('Error saving theme preference: $e');
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _saveThemePreference();
      notifyListeners();
    }
  }
}
