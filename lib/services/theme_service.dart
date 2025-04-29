import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  bool _isDarkMode = true;
  final String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  // Constructor tries to load saved theme preference
  ThemeService() {
    _loadThemePreference();
  }

  // Load saved theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? true; // Default to dark mode
      notifyListeners();
    } catch (e) {
      // If any error occurs, use default dark mode
      _isDarkMode = true;
    }
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      // Handle error if needed
      print('Error saving theme preference: $e');
    }
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  // Set specific theme mode
  void setDarkMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _saveThemePreference();
      notifyListeners();
    }
  }
}