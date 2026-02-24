import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdm_malang/models/amal_usaha_model.dart';
import 'package:pdm_malang/services/api_service.dart';

/// Layanan API amal usaha (public).
/// GET /amal-usaha?page=1&per_page=10&type=pendidikan|kesehatan|sosial|ekonomi
/// Cache: per type, dipakai saat buka halaman lagi atau ganti type tanpa fetch.
class AmalUsahaApiService {
  static final Map<String, List<AmalUsahaItem>> _cacheByType = {};

  /// Ambil data dari cache untuk type tertentu. Key: '' = Semua, atau pendidikan|kesehatan|sosial|ekonomi.
  static List<AmalUsahaItem>? getCached({String? type}) {
    final key = type == null || type.isEmpty ? '' : type;
    final list = _cacheByType[key];
    return list == null ? null : List<AmalUsahaItem>.from(list);
  }

  String get _baseUrl {
    final url = ApiService.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET /amal-usaha
  Future<AmalUsahaListResult> getAmalUsaha({
    int page = 1,
    int perPage = 10,
    String? type,
  }) async {
    try {
      final q = <String, String>{
        'page': '$page',
        'per_page': '$perPage',
      };
      if (type != null && type.isNotEmpty) q['type'] = type;

      final uri = Uri.parse('$_baseUrl/amal-usaha').replace(queryParameters: q);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        return AmalUsahaListResult(
          success: false,
          message: _messageFromBody(response.body),
          data: const [],
          meta: null,
        );
      }

      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      if (map == null) {
        return AmalUsahaListResult(
          success: false,
          message: 'Invalid response',
          data: const [],
          meta: null,
        );
      }

      final list = map['data'];
      final List<AmalUsahaItem> items = [];
      if (list is List) {
        for (final e in list) {
          if (e is Map<String, dynamic>) {
            try {
              final item = AmalUsahaItem.fromJson(e);
              if (item.isActive) items.add(item);
            } catch (_) {}
          }
        }
      }
      final cacheKey = type == null || type.isEmpty ? '' : type;
      _cacheByType[cacheKey] = items;

      Map<String, dynamic>? meta;
      if (map['meta'] is Map) {
        meta = Map<String, dynamic>.from(map['meta'] as Map);
      }

      return AmalUsahaListResult(
        success: true,
        message: '',
        data: items,
        meta: meta,
      );
    } catch (e) {
      return AmalUsahaListResult(
        success: false,
        message: e.toString(),
        data: const [],
        meta: null,
      );
    }
  }

  String _messageFromBody(String body) {
    try {
      final map = jsonDecode(body);
      if (map is Map && map['message'] != null) return map['message'] as String;
    } catch (_) {}
    return 'Request failed';
  }
}

class AmalUsahaListResult {
  final bool success;
  final String message;
  final List<AmalUsahaItem> data;
  final Map<String, dynamic>? meta;

  AmalUsahaListResult({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });
}
