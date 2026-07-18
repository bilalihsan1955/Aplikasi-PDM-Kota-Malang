import 'package:pdm_malang/models/amal_usaha_model.dart';
import 'package:pdm_malang/services/api/amal_usaha_api_service.dart';

class AmalUsahaRepository {
  final AmalUsahaApiService _apiService;

  AmalUsahaRepository({required AmalUsahaApiService apiService})
      : _apiService = apiService;

  List<AmalUsahaItem>? getCached({String? type}) {
    return AmalUsahaApiService.getCached(type: type);
  }

  Future<AmalUsahaListResult> getAmalUsaha({
    int page = 1,
    int perPage = 10,
    String? type,
  }) async {
    return await _apiService.getAmalUsaha(
      page: page,
      perPage: perPage,
      type: type,
    );
  }

  Future<AmalUsahaItem?> getBySlug(String slug) async {
    return await _apiService.getBySlug(slug);
  }
}
