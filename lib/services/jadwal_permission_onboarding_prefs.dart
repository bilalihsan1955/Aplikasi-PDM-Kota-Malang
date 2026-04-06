import 'package:shared_preferences/shared_preferences.dart';

/// Sekali setelah instal: saat pertama buka halaman jadwal, arahkan ke alur izin Android.
class JadwalPermissionOnboardingPrefs {
  static const String _key = 'jz_android_permission_onboarding_done';

  static Future<bool> isDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_key) ?? false;
  }

  static Future<void> markDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, true);
  }
}
