import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdm_malang/models/news_model.dart';
import 'package:pdm_malang/services/api_service.dart';

/// Layanan API berita (public, tanpa auth).
/// Menggunakan [ApiService.baseUrl] dari .env.
class NewsApiService {
  String get _baseUrl {
    final url = ApiService.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET /news?page=&per_page=&category_id=&search=
  Future<NewsListResult> getNews({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? search,
  }) async {
    try {
      final q = <String, String>{
        'page': '$page',
        'per_page': '$perPage',
      };
      if (categoryId != null) q['category_id'] = '$categoryId';
      if (search != null && search.trim().isNotEmpty) q['search'] = search.trim();

      final uri = Uri.parse('$_baseUrl/news').replace(queryParameters: q);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        return NewsListResult(
          success: false,
          message: _messageFromBody(response.body),
          data: const [],
          meta: null,
        );
      }

      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      if (map == null) {
        return NewsListResult(success: false, message: 'Invalid response', data: const [], meta: null);
      }

      final list = map['data'];
      final List<NewsModel> items = [];
      if (list is List) {
        for (final e in list) {
          if (e is Map<String, dynamic>) {
            try {
              items.add(NewsModel.fromJson(e));
            } catch (_) {
              // skip invalid item
            }
          }
        }
      }

      Map<String, dynamic>? meta;
      if (map['meta'] is Map) {
        meta = Map<String, dynamic>.from(map['meta'] as Map);
      }

      return NewsListResult(
        success: true,
        message: '',
        data: items,
        meta: meta,
      );
    } catch (e) {
      return NewsListResult(
        success: false,
        message: e.toString(),
        data: const [],
        meta: null,
      );
    }
  }

  /// GET /news/featured → single news object
  Future<NewsModel?> getFeatured() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/news/featured'),
        headers: _headers,
      );

      if (response.statusCode != 200) return null;
      final map = jsonDecode(response.body);
      if (map is Map<String, dynamic>) {
        return NewsModel.fromJson(map);
      }
      // some APIs wrap in { "data": {...} }
      if (map is Map && map['data'] != null && map['data'] is Map) {
        return NewsModel.fromJson(Map<String, dynamic>.from(map['data'] as Map));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// GET /news/latest → array of 5 latest
  Future<List<NewsModel>> getLatest() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/news/latest'),
        headers: _headers,
      );

      if (response.statusCode != 200) return [];
      final body = jsonDecode(response.body);
      final list = body is List ? body : (body is Map ? (body['data'] as List?) ?? [] : []);
      final List<NewsModel> items = [];
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          try {
            items.add(NewsModel.fromJson(e));
          } catch (_) {}
        }
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  /// GET /news/{slug}
  Future<NewsModel?> getBySlug(String slug) async {
    if (slug.isEmpty) return null;
    try {
      final encodedSlug = Uri.encodeComponent(slug);
      final uri = Uri.parse('$_baseUrl/news/$encodedSlug');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);

      Map<String, dynamic>? raw;
      if (body is Map) {
        final m = Map<String, dynamic>.from(body);
        if (m['data'] is Map) {
          raw = Map<String, dynamic>.from(m['data'] as Map);
        } else if (m['news'] is Map) {
          raw = Map<String, dynamic>.from(m['news'] as Map);
        } else if (m['id'] != null || m['title'] != null) {
          raw = m;
        }
      }
      if (raw != null) {
        return NewsModel.fromJson(raw);
      }
      return null;
    } catch (_) {
      return null;
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

class NewsListResult {
  final bool success;
  final String message;
  final List<NewsModel> data;
  final Map<String, dynamic>? meta;

  NewsListResult({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });
}
