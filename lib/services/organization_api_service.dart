import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdm_malang/models/organization_model.dart';
import 'package:pdm_malang/services/api_service.dart';

/// Layanan API organisasi (profil & struktur).
/// GET /organization/profile — GET /organization/structure
/// Cache: data disimpan setelah load sukses, dipakai saat buka halaman lagi tanpa fetch.
class OrganizationApiService {
  static OrganizationProfileModel? _cachedProfile;
  static List<OrganizationStructureModel> _cachedStructure = [];
  static bool get hasCachedData => _cachedProfile != null || _cachedStructure.isNotEmpty;

  /// Ambil data dari cache (tanpa request). Dipakai saat buka halaman About PDM lagi.
  static OrganizationCached? getCached() {
    if (_cachedProfile == null && _cachedStructure.isEmpty) return null;
    return OrganizationCached(profile: _cachedProfile, structure: List.from(_cachedStructure));
  }

  String get _baseUrl {
    final url = ApiService.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET /organization/profile
  Future<OrganizationProfileResult> getProfile() async {
    try {
      final uri = Uri.parse('$_baseUrl/organization/profile');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        return OrganizationProfileResult(
          success: false,
          message: _messageFromBody(response.body),
          data: null,
        );
      }

      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      if (map == null) {
        return OrganizationProfileResult(
          success: false,
          message: 'Invalid response',
          data: null,
        );
      }

      final data = map['data'];
      OrganizationProfileModel? profile;
      if (data is Map<String, dynamic>) {
        profile = OrganizationProfileModel.fromJson(data);
      }

      if (profile != null) _cachedProfile = profile;
      return OrganizationProfileResult(
        success: true,
        message: '',
        data: profile,
      );
    } catch (e) {
      return OrganizationProfileResult(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  /// GET /organization/structure
  Future<OrganizationStructureResult> getStructure() async {
    try {
      final uri = Uri.parse('$_baseUrl/organization/structure');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        return OrganizationStructureResult(
          success: false,
          message: _messageFromBody(response.body),
          data: const [],
        );
      }

      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      if (map == null) {
        return OrganizationStructureResult(
          success: false,
          message: 'Invalid response',
          data: const [],
        );
      }

      final list = map['data'];
      final List<OrganizationStructureModel> items = [];
      if (list is List) {
        for (final e in list) {
          if (e is Map<String, dynamic>) {
            try {
              items.add(OrganizationStructureModel.fromJson(e));
            } catch (_) {}
          }
        }
      }
      items.sort((a, b) => a.order.compareTo(b.order));
      _cachedStructure = List.from(items);

      return OrganizationStructureResult(
        success: true,
        message: '',
        data: items,
      );
    } catch (e) {
      return OrganizationStructureResult(
        success: false,
        message: e.toString(),
        data: const [],
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

/// Data organisasi yang di-cache (profil + struktur).
class OrganizationCached {
  final OrganizationProfileModel? profile;
  final List<OrganizationStructureModel> structure;

  OrganizationCached({this.profile, required this.structure});
}

class OrganizationProfileResult {
  final bool success;
  final String message;
  final OrganizationProfileModel? data;

  OrganizationProfileResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class OrganizationStructureResult {
  final bool success;
  final String message;
  final List<OrganizationStructureModel> data;

  OrganizationStructureResult({
    required this.success,
    required this.message,
    required this.data,
  });
}
