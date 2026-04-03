import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/auth/auth_api_service.dart';
import '../services/auth/auth_action_result.dart';
import '../services/auth/auth_avatar_cache.dart';
import '../services/auth/auth_local_service.dart';
import '../services/auth/auth_profile_update_result.dart';
import '../services/auth/auth_register_result.dart';
import '../services/auth/password_reset_result.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthApiService _apiService;
  final AuthLocalService _localService;

  /// GET `/user` ke jaringan **hanya sekali** per hidup proses app; setelah sukses, pakai cache saja.
  static bool _userEndpointFetchedThisProcess = false;

  static bool get userEndpointFetchedThisProcess => _userEndpointFetchedThisProcess;

  static void invalidateUserEndpointSync() {
    _userEndpointFetchedThisProcess = false;
  }

  AuthViewModel({
    AuthApiService? apiService,
    AuthLocalService? localService,
  })  : _apiService = apiService ?? AuthApiService(),
        _localService = localService ?? AuthLocalService();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _passwordResetBusy = false;
  bool get passwordResetBusy => _passwordResetBusy;

  Future<AuthRegisterResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (_isSubmitting) {
      return AuthRegisterResult.failure(message: 'Sedang memproses...');
    }

    final normalizedName = name.trim();
    final normalizedEmail = email.trim();
    final normalizedPhone = phone.trim();

    if (normalizedName.isEmpty ||
        normalizedEmail.isEmpty ||
        normalizedPhone.isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty) {
      return AuthRegisterResult.failure(message: 'Semua kolom harus diisi.');
    }

    if (password != passwordConfirmation) {
      return AuthRegisterResult.failure(
        message: 'Password dan konfirmasi password tidak sama.',
      );
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await _apiService.register(
        name: normalizedName,
        email: normalizedEmail,
        phone: normalizedPhone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (result.success && result.user != null && result.token != null) {
        await _localService.saveSession(user: result.user!, token: result.token!);
        prefetchAuthAvatarUrl(result.user!.avatar);
        invalidateUserEndpointSync();
      }

      return result;
    } catch (e) {
      // ignore: avoid_print
      print('[AuthViewModel][register] $e');
      return AuthRegisterResult.failure(
        message: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<AuthRegisterResult> login({
    required String email,
    required String password,
  }) async {
    if (_isSubmitting) {
      return AuthRegisterResult.failure(message: 'Sedang memproses...');
    }

    final normalizedEmail = email.trim();
    final normalizedPassword = password;

    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      return AuthRegisterResult.failure(message: 'Email dan password harus diisi.');
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await _apiService.login(
        email: normalizedEmail,
        password: normalizedPassword,
      );

      if (result.success && result.user != null && result.token != null) {
        await _localService.saveSession(user: result.user!, token: result.token!);
        prefetchAuthAvatarUrl(result.user!.avatar);
        invalidateUserEndpointSync();
      }

      return result;
    } catch (e) {
      // ignore: avoid_print
      print('[AuthViewModel][login] $e');
      return AuthRegisterResult.failure(
        message: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<AuthActionResult> logout() async {
    if (_isSubmitting) {
      return AuthActionResult.failure('Sedang memproses...');
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final token = await _localService.getToken();
      if (token == null || token.isEmpty) {
        // Jika token tidak ada, tetap bersihkan data lokal.
        await _localService.clearAllLocalData();
        invalidateUserEndpointSync();
        return AuthActionResult.success('Logout successful');
      }

      final result = await _apiService.logout(token: token);

      if (result.success) {
        await _localService.clearAllLocalData();
        invalidateUserEndpointSync();
      }

      return result;
    } catch (e) {
      // ignore: avoid_print
      print('[AuthViewModel][logout] $e');
      return AuthActionResult.failure('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// GET `/user` — **HTTP hanya sekali** per proses app; selanjutnya baca cache (halaman Akun).
  Future<AuthProfileUpdateResult> fetchCurrentUser() async {
    final token = await _localService.getToken();
    if (token == null || token.isEmpty) {
      return AuthProfileUpdateResult.failure(
        message: 'Sesi tidak valid. Silakan login lagi.',
      );
    }

    if (_userEndpointFetchedThisProcess) {
      final u =
          AuthLocalService.peekCachedUserSync() ?? await _localService.getCachedUser();
      return AuthProfileUpdateResult.success(
        message: 'OK',
        user: u,
      );
    }

    try {
      final result = await _apiService.fetchCurrentUser(token: token);
      if (result.success && result.user != null) {
        final cached = await _localService.getCachedUser();
        final merged = cached != null
            ? result.user!.mergedWithServer(cached)
            : result.user!;
        await _localService.saveCachedUser(merged);
        prefetchAuthAvatarUrl(merged.avatar);
        _userEndpointFetchedThisProcess = true;
        return AuthProfileUpdateResult.success(
          message: result.message,
          user: merged,
        );
      }
      return result;
    } catch (e) {
      // ignore: avoid_print
      print('[AuthViewModel][fetchCurrentUser] $e');
      return AuthProfileUpdateResult.failure(
        message: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }

  Future<AuthProfileUpdateResult> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? nbm,
    String? password,
    String? passwordConfirmation,
    Uint8List? avatarBytes,
  }) async {
    if (_isSubmitting) {
      return AuthProfileUpdateResult.failure(message: 'Sedang memproses...');
    }

    final token = await _localService.getToken();
    if (token == null || token.isEmpty) {
      return AuthProfileUpdateResult.failure(
        message: 'Sesi tidak valid. Silakan login lagi.',
      );
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await _apiService.updateProfile(
        token: token,
        name: name.trim(),
        email: email.trim(),
        phone: phone?.trim(),
        nbm: nbm?.trim(),
        password: password,
        passwordConfirmation: passwordConfirmation,
        avatarBytes: avatarBytes,
      );

      if (result.success && result.user != null) {
        final prev = await _localService.getCachedUser();
        final merged = prev != null
            ? result.user!.mergedWithServer(prev)
            : result.user!;
        await _localService.saveCachedUser(merged);
        prefetchAuthAvatarUrl(merged.avatar);
        _userEndpointFetchedThisProcess = true;
        return AuthProfileUpdateResult.success(
          message: result.message,
          user: merged,
        );
      }

      return result;
    } catch (e) {
      // ignore: avoid_print
      print('[AuthViewModel][updateProfile] $e');
      return AuthProfileUpdateResult.failure(
        message: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<PasswordResetOtpSendResult> sendPasswordResetOtp(String email) async {
    if (_passwordResetBusy) {
      return PasswordResetOtpSendResult.fail('Sedang memproses...');
    }
    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return PasswordResetOtpSendResult.fail('Masukkan alamat email yang valid.');
    }
    _passwordResetBusy = true;
    notifyListeners();
    try {
      return await _apiService.sendPasswordResetOtp(email: trimmed);
    } finally {
      _passwordResetBusy = false;
      notifyListeners();
    }
  }

  Future<PasswordResetOtpVerifyResult> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    if (_passwordResetBusy) {
      return PasswordResetOtpVerifyResult.fail('Sedang memproses...');
    }
    if (otp.trim().length < 4) {
      return PasswordResetOtpVerifyResult.fail('Masukkan kode OTP lengkap.');
    }
    _passwordResetBusy = true;
    notifyListeners();
    try {
      return await _apiService.verifyPasswordResetOtp(
        email: email.trim(),
        otp: otp.trim(),
      );
    } finally {
      _passwordResetBusy = false;
      notifyListeners();
    }
  }

  Future<PasswordResetSubmitResult> submitPasswordReset({
    required String verificationToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (_passwordResetBusy) {
      return const PasswordResetSubmitResult(
        success: false,
        message: 'Sedang memproses...',
      );
    }
    if (password.isEmpty) {
      return const PasswordResetSubmitResult(
        success: false,
        message: 'Kata sandi baru harus diisi.',
      );
    }
    if (password != passwordConfirmation) {
      return const PasswordResetSubmitResult(
        success: false,
        message: 'Konfirmasi kata sandi tidak sama.',
      );
    }
    _passwordResetBusy = true;
    notifyListeners();
    try {
      return await _apiService.resetPasswordWithToken(
        verificationToken: verificationToken,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } finally {
      _passwordResetBusy = false;
      notifyListeners();
    }
  }
}

