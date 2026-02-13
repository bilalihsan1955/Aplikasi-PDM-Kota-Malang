import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  /// Base URL dari .env (API_BASE_URL). Fallback jika belum di-set.
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://your-domain.com/api/v1';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers dasar
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Headers dengan authentication
  Map<String, String> _headersWithAuth(String token) => {
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
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fcm/token'),
        headers: _headersWithAuth(userToken),
        body: jsonEncode({
          'fcm_token': fcmToken,
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
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Success',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Request failed',
          data: data['data'],
        );
      }
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
