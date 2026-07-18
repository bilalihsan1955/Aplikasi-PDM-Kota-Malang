import 'dart:typed_data';

import 'package:pdm_malang/models/auth_user_model.dart';
import 'package:pdm_malang/services/auth/auth_api_service.dart';
import 'package:pdm_malang/services/auth/auth_local_service.dart';
import 'package:pdm_malang/services/auth/auth_action_result.dart';
import 'package:pdm_malang/services/auth/auth_profile_update_result.dart';
import 'package:pdm_malang/services/auth/auth_refresh_result.dart';
import 'package:pdm_malang/services/auth/auth_register_result.dart';
import 'package:pdm_malang/services/auth/password_reset_result.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final AuthLocalService _localService;

  AuthRepository({
    required AuthApiService apiService,
    required AuthLocalService localService,
  })  : _apiService = apiService,
        _localService = localService;

  // Local Storage Methods
  Future<AuthUser?> getCachedUser() => _localService.getCachedUser();
  Future<void> saveCachedUser(AuthUser user) => _localService.saveCachedUser(user);
  Future<String?> getToken() => _localService.getToken();
  Future<void> updateStoredTokenIfDifferent(String newToken) => _localService.updateStoredTokenIfDifferent(newToken);
  Future<void> saveSession({required AuthUser user, required String token}) => _localService.saveSession(user: user, token: token);
  Future<bool> hasCompletedOnboarding() => _localService.hasCompletedOnboarding();
  Future<void> setOnboardingCompleted() => _localService.setOnboardingCompleted();
  Future<bool> isLoggedIn() => _localService.isLoggedIn();
  Future<String> resolveInitialLocation() => _localService.resolveInitialLocation();
  Future<void> clearAllLocalData() => _localService.clearAllLocalData();
  
  static AuthUser? peekCachedUserSync() => AuthLocalService.peekCachedUserSync();

  // Network API Methods
  Future<AuthRegisterResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _apiService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  Future<AuthRegisterResult> login({
    required String email,
    required String password,
  }) async {
    return await _apiService.login(email: email, password: password);
  }

  Future<AuthRefreshResult> refreshToken({required String token}) async {
    return await _apiService.refreshToken(token: token);
  }

  Future<AuthActionResult> logout({required String token}) async {
    return await _apiService.logout(token: token);
  }

  Future<AuthProfileUpdateResult> fetchCurrentUser({required String token}) async {
    return await _apiService.fetchCurrentUser(token: token);
  }

  Future<AuthProfileUpdateResult> updateProfile({
    required String token,
    required String name,
    required String email,
    String? phone,
    String? nbm,
    String? password,
    String? passwordConfirmation,
    Uint8List? avatarBytes,
  }) async {
    return await _apiService.updateProfile(
      token: token,
      name: name,
      email: email,
      phone: phone,
      nbm: nbm,
      password: password,
      passwordConfirmation: passwordConfirmation,
      avatarBytes: avatarBytes,
    );
  }

  Future<PasswordResetOtpSendResult> sendPasswordResetOtp({required String email}) async {
    return await _apiService.sendPasswordResetOtp(email: email);
  }

  Future<PasswordResetOtpVerifyResult> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    return await _apiService.verifyPasswordResetOtp(email: email, otp: otp);
  }

  Future<PasswordResetSubmitResult> resetPasswordWithToken({
    required String verificationToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _apiService.resetPasswordWithToken(
      verificationToken: verificationToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
