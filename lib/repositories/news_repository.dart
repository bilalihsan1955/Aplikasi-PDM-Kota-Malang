import 'package:pdm_malang/models/news_model.dart';
import 'package:pdm_malang/services/api/news_api_service.dart';

import 'package:pdm_malang/utils/network_error_mapper.dart';

class NewsRepository {
  final NewsApiService _apiService;

  NewsRepository({required NewsApiService apiService})
      : _apiService = apiService;

  Future<NewsListResult> getNews({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? search,
  }) async {
    return await _apiService.getNews(
      page: page,
      perPage: perPage,
      categoryId: categoryId,
      search: search,
    );
  }

  Future<NewsModel?> getFeaturedNews() async {
    return await _apiService.getFeatured();
  }

  Future<List<NewsModel>> getLatestNews() async {
    return await _apiService.getLatest();
  }

  Future<NewsModel?> getNewsBySlug(String slug) async {
    return await _apiService.getBySlug(slug);
  }

  String getFriendlyError(String raw) =>
      NetworkErrorMapper.toFriendly(raw, fallbackContext: 'berita');
}
