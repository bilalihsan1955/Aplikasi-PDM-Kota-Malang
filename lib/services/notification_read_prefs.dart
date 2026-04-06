import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan ID notifikasi yang sudah dibaca di perangkat (API belum punya mark-read).
class NotificationReadPrefs {
  static const String _key = 'notification_local_read_ids';

  static Future<Set<int>> getReadIds() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw);
      if (list is! List) return {};
      return list
          .map((e) {
            if (e is int) return e;
            if (e is num) return e.toInt();
            if (e is String) return int.tryParse(e) ?? -1;
            return -1;
          })
          .where((id) => id >= 0)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> addReadId(int id) async {
    final ids = await getReadIds();
    if (ids.add(id)) {
      await _save(ids);
    }
  }

  static Future<void> addReadIds(Iterable<int> idsToAdd) async {
    final ids = await getReadIds();
    var changed = false;
    for (final id in idsToAdd) {
      if (ids.add(id)) changed = true;
    }
    if (changed) await _save(ids);
  }

  static Future<void> _save(Set<int> ids) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(ids.toList()..sort()));
  }

  /// Panggil saat logout agar akun lain tidak terkena ID yang bentrok.
  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}
