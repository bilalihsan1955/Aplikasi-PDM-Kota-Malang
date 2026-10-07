import 'package:flutter_test/flutter_test.dart';
import 'package:pdm_malang/models/news_model.dart';
import 'package:pdm_malang/repositories/news_repository.dart';
import 'package:pdm_malang/services/api/news_api_service.dart';
import 'package:pdm_malang/utils/network_error_mapper.dart';
import 'package:pdm_malang/view_models/news_view_model.dart';

class FakeNewsRepository implements NewsRepository {
  List<NewsModel> fakeNews = [];
  bool shouldSucceed = true;
  String errorMessage = 'Failed to load';

  @override
  Future<NewsListResult> getNews({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? search,
  }) async {
    if (!shouldSucceed) {
      return NewsListResult(
        success: false,
        message: errorMessage,
        data: const [],
      );
    }
    return NewsListResult(
      success: true,
      message: 'OK',
      data: fakeNews,
    );
  }

  @override
  Future<NewsModel?> getFeaturedNews() async => null;

  @override
  Future<List<NewsModel>> getLatestNews() async => [];

  @override
  Future<NewsModel?> getNewsBySlug(String slug) async => null;

  @override
  String getFriendlyError(String raw) =>
      NetworkErrorMapper.toFriendly(raw, fallbackContext: 'berita');
}

void main() {
  group('NewsViewModel Tests', () {
    late FakeNewsRepository fakeRepo;
    late NewsViewModel viewModel;

    final sampleNews1 = NewsModel(
      id: 1,
      title: 'Kajian Rutin Muhammadiyah Malang',
      slug: 'kajian-rutin',
      excerpt: 'Kajian rutin bulanan membahas fiqih',
      content: 'Isi lengkap kajian...',
      image: 'https://example.com/img1.jpg',
      status: 'published',
      views: 120,
      isFeatured: false,
      category: NewsCategory(id: 1, name: 'Tabligh', slug: 'tabligh'),
    );

    final sampleNews2 = NewsModel(
      id: 2,
      title: 'Pemberdayaan Ekonomi Warga',
      slug: 'pemberdayaan-ekonomi',
      excerpt: 'Program pemberdayaan UMKM',
      content: 'Isi pemberdayaan...',
      image: 'https://example.com/img2.jpg',
      status: 'published',
      views: 45,
      isFeatured: true,
      category: NewsCategory(id: 2, name: 'Ekonomi', slug: 'ekonomi'),
    );

    setUp(() {
      fakeRepo = FakeNewsRepository();
      viewModel = NewsViewModel(repository: fakeRepo);
    });

    test('initial state is correct', () {
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.selectedTag, equals('Semua'));
      expect(viewModel.searchQuery, isEmpty);
      expect(viewModel.errorMessage, isEmpty);
      expect(viewModel.filteredNews, isEmpty);
      expect(viewModel.categories, equals(['Semua']));
    });

    test('loadNews successfully updates news and dynamic categories', () async {
      fakeRepo.fakeNews = [sampleNews1, sampleNews2];
      fakeRepo.shouldSucceed = true;

      await viewModel.loadNews();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isEmpty);
      expect(viewModel.filteredNews.length, equals(2));
      expect(viewModel.categories, containsAll(['Semua', 'Tabligh', 'Ekonomi']));
    });

    test('filteredNews accurately filters by selected tag and search query', () async {
      fakeRepo.fakeNews = [sampleNews1, sampleNews2];
      await viewModel.loadNews();

      viewModel.setTag('Tabligh');
      expect(viewModel.selectedTag, equals('Tabligh'));
      expect(viewModel.filteredNews.length, equals(1));
      expect(viewModel.filteredNews.first.title, equals('Kajian Rutin Muhammadiyah Malang'));

      viewModel.resetFilters();
      viewModel.setSearchQuery('ekonomi');
      expect(viewModel.filteredNews.length, equals(1));
      expect(viewModel.filteredNews.first.title, equals('Pemberdayaan Ekonomi Warga'));

      viewModel.setSearchQuery('');
      expect(viewModel.filteredNews.length, equals(2));
    });

    test('loadNews sets friendly error message on failure', () async {
      fakeRepo.shouldSucceed = false;
      fakeRepo.errorMessage = 'SocketException: Connection refused';

      await viewModel.loadNews();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.filteredNews, isEmpty);
      expect(viewModel.errorMessage, contains('Koneksi internet'));
    });
  });
}
