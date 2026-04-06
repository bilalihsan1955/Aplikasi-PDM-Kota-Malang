import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// ID / sidik judul+isi notifikasi yang user hapus dari daftar (hanya lokal; API tidak punya delete).
class NotificationDeletedPrefs {
  static const String _idsKey = 'notification_local_deleted_ids';
  static const String _fpKey = 'notification_local_deleted_fingerprints';

  static String fingerprint(String title, String body) =>
      '${title.trim()}\u001e${body.trim()}';

  static Future<Set<int>> getDeletedIds() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_idsKey);
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
          .where((id) => id > 0)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<Set<String>> getDeletedFingerprints() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_fpKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw);
      if (list is! List) return {};
      return list.map((e) => e.toString()).where((s) => s.isNotEmpty).toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> addDeletedId(int id) async {
    if (id <= 0) return;
    final ids = await getDeletedIds();
    if (ids.add(id)) await _saveIds(ids);
  }

  static Future<void> addDeletedFingerprint(String title, String body) async {
    final fp = fingerprint(title, body);
    if (fp == '\u001e') return;
    final set = await getDeletedFingerprints();
    if (set.add(fp)) await _saveFingerprints(set);
  }

  /// Setelah user menghapus satu baris: simpan id server (jika ada) + sidik agar tidak muncul lagi setelah refresh.
  static Future<void> recordDeletion({
    required int id,
    required String title,
    required String body,
  }) async {
    await addDeletedFingerprint(title, body);
    await addDeletedId(id);
  }

  static Future<void> _saveIds(Set<int> ids) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_idsKey, jsonEncode(ids.toList()..sort()));
  }

  static Future<void> _saveFingerprints(Set<String> fps) async {
    final p = await SharedPreferences.getInstance();
    final list = fps.toList()..sort();
    await p.setString(_fpKey, jsonEncode(list));
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_idsKey);
    await p.remove(_fpKey);
  }
}
