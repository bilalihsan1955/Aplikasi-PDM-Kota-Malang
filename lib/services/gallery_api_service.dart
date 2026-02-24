import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdm_malang/models/gallery_model.dart';
import 'package:pdm_malang/services/api_service.dart';

/// Layanan API galeri (public).
/// GET /galleries → { "data": [ { "id", "title", "description", "image", "type", "created_at" } ] }
/// Cache: data disimpan setelah load sukses, dipakai saat buka halaman lagi tanpa fetch.
class GalleryApiService {
  static List<GalleryModel>? _cachedList;

  /// Ambil data dari cache (tanpa request). Dipakai saat buka halaman Galeri lagi.
  static List<GalleryModel>? getCached() =>
      _cachedList == null ? null : List<GalleryModel>.from(_cachedList!);

  String get _baseUrl {
    final url = ApiService.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET /galleries — daftar galeri dari API.
  Future<GalleryListResult> getGallery({int page = 1, int perPage = 20}) async {
    try {
      final q = <String, String>{
        'page': '$page',
        'per_page': '$perPage',
      };
      final uri = Uri.parse('$_baseUrl/galleries').replace(queryParameters: q);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        return GalleryListResult(
          success: false,
          message: _messageFromBody(response.body),
          data: const [],
          meta: null,
        );
      }

      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      if (map == null) {
        return GalleryListResult(
          success: false,
          message: 'Invalid response',
          data: const [],
          meta: null,
        );
      }

      final list = map['data'];
      final List<GalleryModel> items = [];
      if (list is List) {
        for (final e in list) {
          if (e is Map<String, dynamic>) {
            try {
              items.add(GalleryModel.fromJson(e));
            } catch (_) {}
          }
        }
      }
      _cachedList = items;

      Map<String, dynamic>? meta;
      if (map['meta'] is Map) {
        meta = Map<String, dynamic>.from(map['meta'] as Map);
      }

      return GalleryListResult(
        success: true,
        message: '',
        data: items,
        meta: meta,
      );
    } catch (e) {
      return GalleryListResult(
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

class GalleryListResult {
  final bool success;
  final String message;
  final List<GalleryModel> data;
  final Map<String, dynamic>? meta;

  GalleryListResult({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });
}
