import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/notification_model.dart';

class NotificationApiService {
  static String get _baseUrl => ApiService.baseUrl;

  static Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// GET /notifikasi?user_id={userId}&limit={limit}
  static Future<NotificationListResult> fetchNotifications({
    required String token,
    required int userId,
    int limit = 60,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/notifikasi').replace(
        queryParameters: {
          'user_id': userId.toString(),
          'limit': limit.toString(),
        },
      );
      final response = await http.get(uri, headers: _authHeaders(token));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = _extractNotificationList(decoded);
        if (list == null) {
          return NotificationListResult(
            success: false,
            message: 'Format respons tidak dikenali',
          );
        }

        final notifications = list
            .map((e) {
              if (e is! Map) {
                throw FormatException('Item notifikasi bukan objek');
              }
              return NotificationModel.fromJson(Map<String, dynamic>.from(e));
            })
            .toList();

        return NotificationListResult(
          success: true,
          data: notifications,
        );
      }

      if (response.statusCode == 401) {
        return NotificationListResult(
          success: false,
          message: 'Sesi habis, silakan login ulang',
        );
      }

      return NotificationListResult(
        success: false,
        message: 'Gagal memuat notifikasi (${response.statusCode})',
      );
    } catch (e) {
      return NotificationListResult(
        success: false,
        message: e is FormatException
            ? 'Format data notifikasi tidak valid'
            : 'Tidak dapat terhubung ke server',
      );
    }
  }

  /// Mendukung: array langsung, `{ "data": [ ... ] }`, atau `{ "data": { "notifications"|"items": [ ... ] } }`.
  static List<dynamic>? _extractNotificationList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map) return null;
    final data = decoded['data'];
    if (data is List) return data;
    if (data is Map) {
      final dm = Map<String, dynamic>.from(data);
      for (final key in ['notifications', 'items', 'records', 'results']) {
        final v = dm[key];
        if (v is List) return v;
      }
    }
    return null;
  }
}

class NotificationListResult {
  final bool success;
  final String? message;
  final List<NotificationModel>? data;

  NotificationListResult({
    required this.success,
    this.message,
    this.data,
  });
}
