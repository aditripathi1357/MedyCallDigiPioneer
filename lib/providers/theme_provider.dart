// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  // Helper methods for theme-aware colors
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }

  Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
  }

  Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Color getOnSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
}
