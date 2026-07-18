import 'package:pdm_malang/models/news_model.dart';
import 'package:pdm_malang/services/api/news_api_service.dart';

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

  String getFriendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('unreachable') ||
        lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('no internet') ||
        lower.contains('failed host lookup')) {
      return 'Koneksi internet tidak stabil.\nPeriksa jaringan Anda dan coba lagi.';
    }
    if (lower.contains('404') || lower.contains('not found')) {
      return 'Data tidak ditemukan.\nSilakan coba lagi nanti.';
    }
    if (lower.contains('500') || lower.contains('internal server')) {
      return 'Server sedang bermasalah.\nSilakan coba beberapa saat lagi.';
    }
    if (lower.contains('403') ||
        lower.contains('forbidden') ||
        lower.contains('unauthorized')) {
      return 'Akses ditolak.\nSilakan login ulang atau hubungi admin.';
    }
    if (raw.isEmpty) return 'Gagal memuat berita.\nSilakan coba lagi.';
    return 'Terjadi kesalahan.\nSilakan coba lagi nanti.';
  }
}
