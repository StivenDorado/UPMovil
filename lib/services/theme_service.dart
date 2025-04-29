import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el tema de la aplicación
class ThemeService extends ChangeNotifier {
  bool _isDarkMode = false;
  final String _themeKey = 'theme_mode';

  bool get isDarkMode => _isDarkMode;

  ThemeService() {
    _loadThemeFromPrefs();
  }

  /// Carga el tema guardado desde SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error cargando tema: $e');
    }
  }

  /// Guarda la preferencia de tema en SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      print('Error guardando tema: $e');
    }
  }

  /// Cambia entre tema claro y oscuro
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemeToPrefs();
    notifyListeners();
  }

  /// Establece un tema específico
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _saveThemeToPrefs();
      notifyListeners();
    }
  }
}