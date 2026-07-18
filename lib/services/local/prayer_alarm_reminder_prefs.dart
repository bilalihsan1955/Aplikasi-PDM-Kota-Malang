import 'package:shared_preferences/shared_preferences.dart';

/// Preferensi app: alarm & pengingat jadwal sholat (bukan pengganti izin sistem Android).
class PrayerAlarmReminderPrefs {
  static const String _key = 'prayer_alarm_reminder_enabled';

  /// Default: aktif (app boleh menjadwalkan notifikasi jadwal).
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
