import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../../models/auth_user_model.dart';
import '../../services/api_service.dart';
import 'auth_action_result.dart';
import 'auth_profile_update_result.dart';
import 'auth_register_result.dart';
import 'password_reset_result.dart';

class AuthApiService {
  String get _baseUrl {
    final url = ApiService.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  void _logAuthApiError(String tag, http.Response response, Map<String, dynamic> map) {
    // ignore: avoid_print
    print('[AuthApiService][$tag] ERROR status=${response.statusCode} body=${response.body}');
    final err = map['errors'];
    if (err != null) {
      // ignore: avoid_print
      print('[AuthApiService][$tag] errors=$err');
    }
  }

  /// Pesan untuk SnackBar: `message` + baris per field validasi Laravel (`errors`).
  String _validationDisplayMessage(Map<String, dynamic> map, String fallback) {
    final base = map['message']?.toString().trim();
    final errors = _parseErrors(map['errors']);
    if (errors == null || errors.isEmpty) {
      if (base != null && base.isNotEmpty) return base;
      return fallback;
    }
    final buf = StringBuffer();
    if (base != null && base.isNotEmpty) {
      buf.writeln(base);
    }
    for (final entry in errors.entries) {
      final field = entry.key;
      final msgs = entry.value.where((m) => m.isNotEmpty).toList();
      if (msgs.isEmpty) continue;
      buf.writeln('• $field: ${msgs.join(' · ')}');
    }
    return buf.toString().trim();
  }

  Future<AuthRegisterResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/register');

      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
        }),
      );

      final dynamic decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> map =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      // Backend sample Anda:
      // 201:
      // { "success": true, "message": "...", "data": { "user": {...}, "token": "..." } }
      if (response.statusCode == 201) {
        final message = map['message']?.toString() ?? 'Registration successful';
        final data = map['data'];
        final userMap = data is Map ? data['user'] : null;
        final token = data is Map ? data['token']?.toString() : null;

        if (userMap is Map<String, dynamic> && token != null) {
          final user = AuthUser.fromJson(userMap);
          return AuthRegisterResult.success(message: message, user: user, token: token);
        }

        _logAuthApiError('register', response, map);
        return AuthRegisterResult.failure(
          message: _validationDisplayMessage(map, 'Registration failed'),
          errors: _parseErrors(map['errors']),
        );
      }

      // 402 / 422: { "message": "...", "errors": { "field": ["..."] } }
      if (response.statusCode == 402 || response.statusCode == 422) {
        _logAuthApiError('register', response, map);
        final errors = _parseErrors(map['errors']);
        return AuthRegisterResult.failure(
          message: _validationDisplayMessage(map, 'Registration failed'),
          errors: errors,
        );
      }

      _logAuthApiError('register', response, map);
      return AuthRegisterResult.failure(
        message: _validationDisplayMessage(map, 'Registration failed'),
        errors: _parseErrors(map['errors']),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AuthApiService][register] $e');
      return AuthRegisterResult.failure(
        message: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }

  Future<AuthRegisterResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/login');

      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final dynamic decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> map =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      // Sukses: contoh sama seperti register (201).
      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = map['message']?.toString() ?? 'Login successful';
        final data = map['data'];
        final userMap = data is Map ? data['user'] : null;
        final token = data is Map ? data['token']?.toString() : null;

        if (userMap is Map<String, dynamic> && token != null) {
          final user = AuthUser.fromJson(userMap);
          return AuthRegisterResult.success(
            message: message,
            user: user,
            token: token,
          );
        }

        _logAuthApiError('login', response, map);
        return AuthRegisterResult.failure(
          message: _validationDisplayMessage(map, 'Login failed'),
          errors: _parseErrors(map['errors']),
        );
      }

      _logAuthApiError('login', response, map);
      return AuthRegisterResult.failure(
        message: _validationDisplayMessage(map, 'Login failed'),
        errors: _parseErrors(map['errors']),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AuthApiService][login] $e');
      return AuthRegisterResult.failure(
        message: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }

  Map<String, List<String>>? _parseErrors(dynamic raw) {
    if (raw is! Map) return null;
    final out = <String, List<String>>{};

    for (final entry in raw.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is List) {
        out[key] = value.map((e) => e.toString()).toList();
      } else if (value != null) {
        out[key] = [value.toString()];
      }
    }
    return out.isEmpty ? null : out;
  }

  Future<AuthActionResult> logout({
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/logout');
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final dynamic decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> map =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final msg = map['message']?.toString() ?? 'Logout successful';
        return AuthActionResult.success(msg);
      }

      _logAuthApiError('logout', response, map);
      final msg = map['message']?.toString() ?? 'Logout failed';
      return AuthActionResult.failure(msg);
    } catch (e) {
      // ignore: avoid_print
      print('[AuthApiService][logout] $e');
      return AuthActionResult.failure('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  Map<String, String> _authJsonHeaders(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// POST `/user/update` — header JSON + Bearer token; multipart jika ada [avatarBytes].
  /// Mengunggah dari byte (bukan `fromPath`) supaya aman jika file cache image_picker sudah dihapus OS.
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
    try {
      final uri = Uri.parse('$_baseUrl/user/update');
      final http.Response response;

      if (avatarBytes != null && avatarBytes.isNotEmpty) {
        final request = http.MultipartRequest('POST', uri);
        request.headers['Accept'] = 'application/json';
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['name'] = name;
        request.fields['email'] = email;
        request.fields['phone'] = phone ?? '';
        request.fields['nbm'] = nbm ?? '';
        if (password != null && password.isNotEmpty) {
          request.fields['password'] = password;
        }
        if (passwordConfirmation != null && passwordConfirmation.isNotEmpty) {
          request.fields['password_confirmation'] = passwordConfirmation;
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'avatar',
            avatarBytes,
            filename: 'avatar.jpg',
          ),
        );
        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      } else {
        response = await http.post(
          uri,
          headers: _authJsonHeaders(token),
          body: jsonEncode({
            'name': name,
            'email': email,
            'phone': phone ?? '',
            'nbm': nbm ?? '',
            if (password != null && password.isNotEmpty) 'password': password,
            if (passwordConfirmation != null && passwordConfirmation.isNotEmpty)
              'password_confirmation': passwordConfirmation,
          }),
        );
      }

      final dynamic decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> map =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final ok = map['success'] == true;
        if (!ok) {
          _logAuthApiError('updateProfile', response, map);
          return AuthProfileUpdateResult.failure(
            message: _validationDisplayMessage(map, 'Profil gagal diperbarui'),
            errors: _parseErrors(map['errors']),
          );
        }

        final message =
            map['message']?.toString() ?? 'Profile updated successfully';
        final data = map['data'];
        final rawUser = data is Map ? data['user'] : null;
        final userMap = rawUser is Map<String, dynamic>
            ? rawUser
            : rawUser is Map
                ? Map<String, dynamic>.from(rawUser)
                : null;

        if (userMap != null) {
          final user = AuthUser.fromJson(userMap);
          return AuthProfileUpdateResult.success(message: message, user: user);
        }

        return AuthProfileUpdateResult.success(message: message, user: null);
      }

      if (response.statusCode == 402 || response.statusCode == 422) {
        _logAuthApiError('updateProfile', response, map);
        return AuthProfileUpdateResult.failure(
          message: _validationDisplayMessage(map, 'Profil gagal diperbarui'),
          errors: _parseErrors(map['errors']),
        );
      }

      _logAuthApiError('updateProfile', response, map);
      return AuthProfileUpdateResult.failure(
        message: _validationDisplayMessage(map, 'Profil gagal diperbarui'),
        errors: _parseErrors(map['errors']),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AuthApiService][updateProfile] $e');
      return AuthProfileUpdateResult.failure(
        message: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }

  static const String _purposePasswordReset = 'password_reset';

  int? _readExpiresIn(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  Future<PasswordResetOtpSendResult> sendPasswordResetOtp({
    required String email,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/otp/send');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'email': email.trim(),
          'purpose': _purposePasswordReset,
        }),
      );

      final dynamic decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> map =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      final okFlag = map['success'] == true;
      final message = map['message']?.toString() ?? '';

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          okFlag) {
        final data = map['data'];
        final expiresIn = data is Map ? _readExpiresIn(data['expires_in']) : null;
        return PasswordResetOtpSendResult.ok(
          message: message.isNotEmpty
              ? message
              : 'Kode OTP telah dikirim ke email Anda.',
          expiresInSeconds: expiresIn,
        );
      }

      _logAuthApiError('otp/send', response, map);
      return PasswordResetOtpSendResult.fail(
        _validationDisplayMessage(map, 'Gagal mengirim OTP'),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AuthApiService][otp/send] $e');
      return PasswordResetOtpSendResult.fail(
        'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }

  Future<PasswordResetOtpVerifyResult> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/otp/verify');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'email': email.trim(),
          'otp': otp.trim(),
          'purpose': _purposePasswordReset,
        }),
      );

      final dynamic decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> map =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      final okFlag = map['success'] == true;
      final message = map['message']?.toString() ?? '';

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          okFlag) {
        final data = map['data'];
        final token = data is Map
            ? data['verification_token']?.toString()
            : null;
        if (token != null && token.isNotEmpty) {
          return PasswordResetOtpVerifyResult.ok(
            message:
                message.isNotEmpty ? message : 'Email berhasil diverifikasi.',
            verificationToken: token,
          );
        }
      }

      _logAuthApiError('otp/verify', response, map);
      return PasswordResetOtpVerifyResult.fail(
        _validationDisplayMessage(map, 'Kode OTP tidak valid'),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AuthApiService][otp/verify] $e');
      return PasswordResetOtpVerifyResult.fail(
        'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }

  Future<PasswordResetSubmitResult> resetPasswordWithToken({
    required String verificationToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/password/reset');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'verification_token': verificationToken,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final dynamic decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> map =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      final okFlag = map['success'] == true;
      final message = map['message']?.toString() ?? '';

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          okFlag) {
        return PasswordResetSubmitResult(
          success: true,
          message: message.isNotEmpty
              ? message
              : 'Kata sandi berhasil diubah. Silakan login dengan kata sandi baru.',
        );
      }

      _logAuthApiError('password/reset', response, map);
      return PasswordResetSubmitResult(
        success: false,
        message: _validationDisplayMessage(map, 'Gagal mengubah kata sandi'),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AuthApiService][password/reset] $e');
      return const PasswordResetSubmitResult(
        success: false,
        message: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }
}

