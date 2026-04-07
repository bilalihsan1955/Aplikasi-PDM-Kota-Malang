import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Rute + [extra] untuk [GoRouter.go] setelah login/register berhasil.
class PendingAuthRoute {
  const PendingAuthRoute(this.location, this.extra);

  final String location;
  final Object? extra;
}

/// Menyimpan tujuan navigasi (deep link / notifikasi) bila pengguna belum login.
class PendingAuthRedirect {
  static const String _keyLocation = 'pending_post_login_location';
  static const String _keyExtra = 'pending_post_login_extra_json';

  static Map<String, dynamic> _jsonSafeMap(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    for (final e in m.entries) {
      final v = e.value;
      if (v == null || v is String || v is num || v is bool) {
        out[e.key] = v;
      }
    }
    return out;
  }

  static Future<void> save(String location, Object? extra) async {
    final prefs = await SharedPreferences.getInstance();
    final loc = location.trim();
    if (loc.isEmpty) return;
    await prefs.setString(_keyLocation, loc);
    if (extra == null) {
      await prefs.remove(_keyExtra);
      return;
    }
    if (extra is Map) {
      final raw = Map<String, dynamic>.from(
        extra.map((k, v) => MapEntry(k.toString(), v)),
      );
      final safe = _jsonSafeMap(raw);
      if (safe.isEmpty) {
        await prefs.remove(_keyExtra);
      } else {
        await prefs.setString(_keyExtra, jsonEncode(safe));
      }
      return;
    }
    await prefs.remove(_keyExtra);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLocation);
    await prefs.remove(_keyExtra);
  }

  /// Ambil dan hapus dari penyimpanan (sekali pakai setelah auth sukses).
  static Future<PendingAuthRoute?> take() async {
    final prefs = await SharedPreferences.getInstance();
    final loc = prefs.getString(_keyLocation)?.trim();
    if (loc == null || loc.isEmpty) return null;
    await prefs.remove(_keyLocation);
    final rawExtra = prefs.getString(_keyExtra);
    await prefs.remove(_keyExtra);
    Object? extra;
    if (rawExtra != null && rawExtra.isNotEmpty) {
      try {
        final d = jsonDecode(rawExtra);
        if (d is Map) extra = Map<String, dynamic>.from(d);
      } catch (_) {}
    }
    return PendingAuthRoute(loc, extra);
  }
}
