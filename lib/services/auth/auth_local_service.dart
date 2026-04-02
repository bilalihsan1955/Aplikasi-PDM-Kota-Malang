import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth_user_model.dart';

class AuthLocalService {
  static const String _authUserKey = 'auth_user';
  static const String _authTokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';
  /// Diset sekali setelah onboarding; tidak ikut dihapus saat logout.
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<AuthUser?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_authUserKey);
      if (raw == null || raw.trim().isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AuthUser.fromJson(decoded);
      }
      if (decoded is Map) {
        return AuthUser.fromJson(Map<String, dynamic>.from(decoded));
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal baca cache user: $e');
      return null;
    }
  }

  Future<void> saveCachedUser(AuthUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authUserKey, jsonEncode(user.toJson()));
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal simpan cache user: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _authTokenKey);
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal baca token dari secure storage: $e');
      return null;
    }
  }

  Future<void> saveSession({
    required AuthUser user,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Cache user data (non-token).
    await prefs.setString(_authUserKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);

    // Token must be in secure storage.
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
    } catch (e) {
      // Jangan gagalkan login/register hanya karena secure storage error.
      // Untuk sementara log ke terminal saja.
      // ignore: avoid_print
      print('[AuthLocalService] Gagal simpan token ke secure storage: $e');
    }
  }

  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal baca onboarding: $e');
      return false;
    }
  }

  Future<void> setOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal simpan onboarding: $e');
    }
  }

  /// Sesi masih valid: flag login + token + cache user.
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;
      final token = await getToken();
      final hasToken = token != null && token.trim().isNotEmpty;
      final user = await getCachedUser();
      return loggedInFlag && hasToken && user != null;
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal cek login: $e');
      return false;
    }
  }

  /// Rute awal: home jika masih login; onboarding jika belum pernah; selain itu login.
  Future<String> resolveInitialLocation() async {
    if (await isLoggedIn()) return '/';
    if (!await hasCompletedOnboarding()) return '/onboarding';
    return '/login';
  }

  Future<void> clearAllLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool(_onboardingCompletedKey) ?? false;
      await prefs.clear();
      if (onboardingDone) {
        await prefs.setBool(_onboardingCompletedKey, true);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal clear shared_preferences: $e');
    }

    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal deleteAll secure storage: $e');
    }
  }
}

