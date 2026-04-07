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
    if (list == null) return null;
    return List<AmalUsahaItem>.from(list);
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
      var items = <AmalUsahaItem>[];
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

  /// GET /amal-usaha/{slug} bila tersedia; jika tidak, cari di daftar terpaginasi.
  Future<AmalUsahaItem?> getBySlug(String slug) async {
    final s = slug.trim();
    if (s.isEmpty) return null;
    try {
      final encoded = Uri.encodeComponent(s);
      final uri = Uri.parse('$_baseUrl/amal-usaha/$encoded');
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        Map<String, dynamic>? raw;
        if (body is Map) {
          final m = Map<String, dynamic>.from(body);
          if (m['data'] is Map) {
            raw = Map<String, dynamic>.from(m['data'] as Map);
          } else if (m['id'] != null || m['name'] != null) {
            raw = m;
          }
        }
        if (raw != null) {
          try {
            return AmalUsahaItem.fromJson(raw);
          } catch (_) {}
        }
      }
    } catch (_) {}

    try {
      var page = 1;
      const perPage = 80;
      while (page <= 200) {
        final result = await getAmalUsaha(page: page, perPage: perPage, type: null);
        for (final item in result.data) {
          if (item.slug == s) return item;
        }
        final meta = result.meta;
        final last = meta != null && meta['last_page'] is num
            ? (meta['last_page'] as num).toInt()
            : null;
        if (last != null) {
          if (page >= last || result.data.isEmpty) break;
        } else if (result.data.length < perPage) {
          break;
        }
        page++;
      }
    } catch (_) {}
    return null;
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
