import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth_user_model.dart';

class AuthLocalService {
  static const String _authUserKey = 'auth_user';
  static const String _authTokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';
  /// Diset sekali setelah onboarding; tidak ikut dihapus saat logout.
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Mirror user terakhir (login / GET prefs) agar UI bisa tampil instan tanpa menunggu async.
  static AuthUser? _ramUserCache;
  static final ValueNotifier<AuthUser?> cachedUserNotifier =
      ValueNotifier<AuthUser?>(null);

  static AuthUser? peekCachedUserSync() => _ramUserCache;

  static void _setRamUserCache(AuthUser? user) {
    _ramUserCache = user;
    cachedUserNotifier.value = user;
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<AuthUser?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_authUserKey);
      if (raw == null || raw.trim().isEmpty) {
        _ramUserCache = null;
        return null;
      }
      final decoded = jsonDecode(raw);
      AuthUser? user;
      if (decoded is Map<String, dynamic>) {
        user = AuthUser.fromJson(decoded);
      } else if (decoded is Map) {
        user = AuthUser.fromJson(Map<String, dynamic>.from(decoded));
      } else {
        user = null;
      }
      _setRamUserCache(user);
      return user;
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal baca cache user: $e');
      _setRamUserCache(null);
      return null;
    }
  }

  Future<void> saveCachedUser(AuthUser user) async {
    _setRamUserCache(user);
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

  /// Menyimpan token baru hanya jika berbeda dari yang tersimpan (mis. hasil `/auth/refresh`).
  Future<void> updateStoredTokenIfDifferent(String newToken) async {
    final current = await getToken();
    if (current == newToken) return;
    try {
      await _secureStorage.write(key: _authTokenKey, value: newToken);
    } catch (e) {
      // ignore: avoid_print
      print('[AuthLocalService] Gagal update token: $e');
    }
  }

  Future<void> saveSession({
    required AuthUser user,
    required String token,
  }) async {
    _setRamUserCache(user);
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

    _setRamUserCache(null);
  }
}

