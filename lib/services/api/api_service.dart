import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String _prettyJsonOrRaw(String body) {
  final t = body.trim();
  if (t.isEmpty) return '(empty)';
  try {
    final v = jsonDecode(t);
    return const JsonEncoder.withIndent('  ').convert(v);
  } catch (_) {
    return body;
  }
}

void _logFcmTokenRegisterResponse(Uri uri, http.Response response) {
  final pretty = _prettyJsonOrRaw(response.body);
  final line =
      '────────────────────────────────────────────────────────────';
  // ignore: avoid_print
  print('$line\n'
      '[FCM → server] POST $uri\n'
      'HTTP ${response.statusCode}\n'
      'Response body:\n'
      '$pretty\n'
      '$line');
}

class ApiService {
  /// Base URL dari .env (API_BASE_URL). Tanpa trailing slash agar path `'/fcm/...'` tidak jadi `//`.
  static String get baseUrl {
    final raw =
        dotenv.env['API_BASE_URL'] ?? 'https://your-domain.com/api/v1';
    return raw.trim().replaceAll(RegExp(r'/+$'), '');
  }

  /// Origin situs web (halaman HTML / WebView), **bukan** [baseUrl] API JSON.
  ///
  /// Prefer `WEB_BASE_URL` di `.env` bila frontend beda host dari API.
  /// Tanpa env: jika [baseUrl] berakhiran `/api/v1`, sufiks itu dihapus (host sama).
  static String get webBaseUrl {
    final fromEnv = dotenv.env['WEB_BASE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv.replaceAll(RegExp(r'/+$'), '');
    }
    final api = baseUrl;
    const suffix = '/api/v1';
    if (api.endsWith(suffix)) {
      return api.substring(0, api.length - suffix.length);
    }
    return api;
  }

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers dasar
  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Headers dengan authentication
  Map<String, String> _headersWithAuth(String token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ==================== FCM TOKEN MANAGEMENT ====================

  /// Subscribe ke topic tanpa login (public)
  Future<ApiResponse> subscribeToTopicPublic({
    required String fcmToken,
    required String topic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fcm/subscribe'),
        headers: _headers,
        body: jsonEncode({
          'fcm_token': fcmToken,
          'topic': topic,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Unsubscribe dari topic tanpa login (public)
  Future<ApiResponse> unsubscribeFromTopicPublic({
    required String fcmToken,
    required String topic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fcm/unsubscribe'),
        headers: _headers,
        body: jsonEncode({
          'fcm_token': fcmToken,
          'topic': topic,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Subscribe ke topic dengan authentication (untuk user yang login)
  Future<ApiResponse> subscribeToTopicAuth({
    required String userToken,
    required String topic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fcm/subscribe'),
        headers: _headersWithAuth(userToken),
        body: jsonEncode({
          'topic': topic,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Unsubscribe dari topic dengan authentication
  Future<ApiResponse> unsubscribeFromTopicAuth({
    required String userToken,
    required String topic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fcm/unsubscribe'),
        headers: _headersWithAuth(userToken),
        body: jsonEncode({
          'topic': topic,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Update/Simpan FCM token ke backend (untuk user yang login)
  Future<ApiResponse> updateFcmToken({
    required String userToken,
    required String fcmToken,
    required Map<String, dynamic> device,
  }) async {
    final uri = Uri.parse('$baseUrl/fcm/token');
    try {
      final response = await http.post(
        uri,
        headers: _headersWithAuth(userToken),
        body: jsonEncode({
          'fcm_token': fcmToken,
          'device': device,
        }),
      );

      _logFcmTokenRegisterResponse(uri, response);

      return _handleResponse(response);
    } catch (e) {
      // ignore: avoid_print
      print('[FCM → server] POST $uri\n'
          'Error (no HTTP response): $e');
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Hapus FCM token dari backend (saat logout)
  Future<ApiResponse> deleteFcmToken({
    required String userToken,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/fcm/token'),
        headers: _headersWithAuth(userToken),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // ==================== RESPONSE HANDLER ====================

  ApiResponse _handleResponse(http.Response response) {
    try {
      final dynamic decoded = jsonDecode(response.body);
      final Map<String, dynamic> data =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final bodySuccess = data['success'];
        final ok = bodySuccess is bool ? bodySuccess : true;
        return ApiResponse(
          success: ok,
          message: data['message']?.toString() ?? 'Success',
          data: data['data'],
        );
      }
      return ApiResponse(
        success: false,
        message: data['message']?.toString() ?? 'Request failed',
        data: data['data'],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse response: ${e.toString()}',
      );
    }
  }
}

// ==================== API RESPONSE MODEL ====================

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, data: $data}';
  }
}
