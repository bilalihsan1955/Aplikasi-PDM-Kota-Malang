import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// Menyimpan jadwal sholat harian terakhir dari API agar alarm lokal bisa dijadwalkan ulang
/// saat app dibuka (terminasi / tanpa jaringan) sebelum respons API baru tiba.
class PrayerScheduleLocalCache {
  PrayerScheduleLocalCache._();

  static const String _key = 'prayer_schedule_day_cache_v1';

  static String _todayKey() {
    final n = tz.TZDateTime.now(tz.local);
    final y = n.year.toString().padLeft(4, '0');
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Future<void> save({
    required String city,
    required List<(String name, String timeRaw)> prayers,
  }) async {
    if (prayers.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'date': _todayKey(),
      'city': city,
      'prayers': prayers
          .map((e) => <String, String>{'n': e.$1, 't': e.$2})
          .toList(),
    };
    await prefs.setString(_key, jsonEncode(map));
  }

  static Future<({String city, List<(String name, String timeRaw)> prayers})?>
      loadIfToday() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      if (map['date'] != _todayKey()) return null;
      final city = (map['city'] as String?)?.trim() ?? '';
      final list = map['prayers'];
      if (list is! List) return null;
      final out = <(String, String)>[];
      for (final e in list) {
        if (e is Map) {
          final n = e['n']?.toString().trim() ?? '';
          final t = e['t']?.toString().trim() ?? '';
          if (n.isNotEmpty && t.isNotEmpty) out.add((n, t));
        }
      }
      if (out.isEmpty) return null;
      return (city: city.isEmpty ? 'Lokasi' : city, prayers: out);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
