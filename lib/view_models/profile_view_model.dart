import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get notificationsEnabled => _notificationsEnabled;

  ProfileViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storedMode = await _themeService.getStoredThemeMode();
    if (storedMode != null) {
      _themeMode = storedMode;
    } else {
      // Jika di shared_preferences belum ada isinya, kita tetap biarkan ThemeMode.system
      // Flutter akan otomatis mendeteksi tema sistem melalui MaterialApp(themeMode: ThemeMode.system)
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _themeService.saveThemeMode(mode);
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
}
