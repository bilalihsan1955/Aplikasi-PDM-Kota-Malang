import 'package:flutter/material.dart';
import '../services/fcm_service.dart';
import '../services/prayer_alarm_reminder_prefs.dart';
import '../services/theme_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ThemeService _themeService = ThemeService();

  ThemeMode _themeMode = ThemeMode.system;
  bool _prayerAlarmReminderEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Default true: app boleh menjadwalkan alarm/pengingat jadwal (bukan izin sistem).
  bool get prayerAlarmReminderEnabled => _prayerAlarmReminderEnabled;

  ProfileViewModel() {
    _loadSettings();
    _loadPrayerAlarmReminder();
  }

  Future<void> _loadPrayerAlarmReminder() async {
    _prayerAlarmReminderEnabled = await PrayerAlarmReminderPrefs.isEnabled();
    notifyListeners();
  }

  Future<void> setPrayerAlarmReminderEnabled(bool value) async {
    _prayerAlarmReminderEnabled = value;
    notifyListeners();
    await PrayerAlarmReminderPrefs.setEnabled(value);
    if (!value) {
      await FCMService().cancelAllPrayerScheduleReminders();
    }
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
}
