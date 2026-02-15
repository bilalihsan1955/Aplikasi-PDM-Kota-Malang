import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdm_malang/models/agenda_model.dart';
import 'package:pdm_malang/services/api_service.dart';

/// Layanan API event/agenda (public, tanpa auth).
class EventApiService {
  String get _baseUrl {
    final url = ApiService.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET /events?page=&per_page=&category_id=&status=
  Future<EventListResult> getEvents({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? status,
  }) async {
    try {
      final q = <String, String>{
        'page': '$page',
        'per_page': '$perPage',
      };
      if (categoryId != null) q['category_id'] = '$categoryId';
      if (status != null && status.isNotEmpty) q['status'] = status;

      final uri = Uri.parse('$_baseUrl/events').replace(queryParameters: q);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        return EventListResult(
          success: false,
          message: _messageFromBody(response.body),
          data: const [],
          meta: null,
        );
      }

      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      if (map == null) {
        return EventListResult(
          success: false,
          message: 'Invalid response',
          data: const [],
          meta: null,
        );
      }

      final list = map['data'];
      final List<AgendaModel> items = [];
      if (list is List) {
        for (final e in list) {
          final item = _normalizeEventMap(e);
          if (item != null) {
            try {
              items.add(AgendaModel.fromJson(item));
            } catch (_) {}
          }
        }
      }

      Map<String, dynamic>? meta;
      if (map['meta'] is Map) {
        meta = Map<String, dynamic>.from(map['meta'] as Map);
      }

      return EventListResult(
        success: true,
        message: '',
        data: items,
        meta: meta,
      );
    } catch (e) {
      return EventListResult(
        success: false,
        message: e.toString(),
        data: const [],
        meta: null,
      );
    }
  }

  /// GET /events/upcoming → array of 5 upcoming
  Future<List<AgendaModel>> getUpcoming() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/events/upcoming'),
        headers: _headers,
      );

      if (response.statusCode != 200) return [];
      final body = jsonDecode(response.body);
      final list = body is List ? body : (body is Map ? (body['data'] as List?) ?? [] : []);
      final List<AgendaModel> items = [];
      for (final e in list) {
        final item = _normalizeEventMap(e);
        if (item != null) {
          try {
            items.add(AgendaModel.fromJson(item));
          } catch (_) {}
        }
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  /// GET /events/{slug}
  Future<AgendaModel?> getBySlug(String slug) async {
    if (slug.isEmpty) return null;
    try {
      final encodedSlug = Uri.encodeComponent(slug);
      final uri = Uri.parse('$_baseUrl/events/$encodedSlug');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      Map<String, dynamic>? raw;
      if (body is Map) {
        final m = Map<String, dynamic>.from(body);
        if (m['data'] is Map) {
          raw = Map<String, dynamic>.from(m['data'] as Map);
        } else if (m['event'] is Map) {
          raw = Map<String, dynamic>.from(m['event'] as Map);
        } else if (m['id'] != null || m['title'] != null) {
          raw = m;
        }
      }
      if (raw != null) {
        return AgendaModel.fromJson(raw);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Pastikan map punya key event_time di top level (merge dari child jika ada).
  static Map<String, dynamic>? _normalizeEventMap(dynamic e) {
    if (e == null) return null;
    Map<String, dynamic> out = {};
    if (e is Map) {
      try {
        out = Map<String, dynamic>.from(e);
      } catch (_) {
        for (final entry in e.entries) {
          final k = entry.key?.toString() ?? '';
          if (k.isNotEmpty) out[k] = entry.value;
        }
      }
    }
    if (out.isEmpty) return null;
    if (out['event_time'] == null && out['eventTime'] == null && out['event'] is Map) {
      final inner = out['event'] as Map;
      for (final entry in inner.entries) {
        final k = entry.key?.toString() ?? '';
        if (k.isNotEmpty && out[k] == null) out[k] = entry.value;
      }
    }
    return out;
  }

  String _messageFromBody(String body) {
    try {
      final map = jsonDecode(body);
      if (map is Map && map['message'] != null) return map['message'] as String;
    } catch (_) {}
    return 'Request failed';
  }
}

class EventListResult {
  final bool success;
  final String message;
  final List<AgendaModel> data;
  final Map<String, dynamic>? meta;

  EventListResult({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });
}
