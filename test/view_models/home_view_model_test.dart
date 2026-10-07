import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdm_malang/models/agenda_model.dart';
import 'package:pdm_malang/models/news_model.dart';
import 'package:pdm_malang/repositories/agenda_repository.dart';
import 'package:pdm_malang/repositories/news_repository.dart';
import 'package:pdm_malang/repositories/prayer_repository.dart';
import 'package:pdm_malang/services/api/event_api_service.dart';
import 'package:pdm_malang/services/api/news_api_service.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';

class FakeNewsRepository implements NewsRepository {
  List<NewsModel> fakeNews = [];
  List<NewsModel> fakeLatest = [];

  @override
  Future<NewsListResult> getNews({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? search,
  }) async {
    return NewsListResult(
      success: true,
      message: 'OK',
      data: fakeNews,
    );
  }

  @override
  Future<NewsModel?> getFeaturedNews() async => null;

  @override
  Future<List<NewsModel>> getLatestNews() async => fakeLatest;

  @override
  Future<NewsModel?> getNewsBySlug(String slug) async => null;

  @override
  String getFriendlyError(String raw) => raw;
}

class FakeAgendaRepository implements AgendaRepository {
  List<AgendaModel> fakeUpcoming = [];

  @override
  Future<EventListResult> getEvents({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? status,
  }) async {
    return EventListResult(
      success: true,
      message: 'OK',
      data: fakeUpcoming,
    );
  }

  @override
  Future<List<AgendaModel>> getUpcomingEvents() async => fakeUpcoming;

  @override
  Future<AgendaModel?> getAgendaBySlug(String slug) async => null;

  @override
  String getFriendlyError(String raw) => raw;
}

class FakePrayerRepository implements PrayerRepository {
  @override
  Future<Position?> getCurrentPosition() async => null;

  @override
  Future<PrayerTimeResult?> getTodayPrayerTimes({
    double? lat,
    double? lng,
    bool useDeviceLocation = true,
  }) async => null;

  @override
  Future<double?> getQiblaDirection({double? lat, double? lng}) async => null;
}

void main() {
  group('HomeViewModel Tests', () {
    late FakeNewsRepository fakeNewsRepo;
    late FakeAgendaRepository fakeAgendaRepo;
    late FakePrayerRepository fakePrayerRepo;
    late HomeViewModel viewModel;

    final testNews1 = NewsModel(
      id: 1,
      title: 'Berita A',
      slug: 'berita-a',
      excerpt: 'Ringkasan A',
      content: 'Konten A',
      image: '',
      status: 'published',
      views: 10,
      isFeatured: true,
    );

    final testNews2 = NewsModel(
      id: 2,
      title: 'Berita B',
      slug: 'berita-b',
      excerpt: 'Ringkasan B',
      content: 'Konten B',
      image: '',
      status: 'published',
      views: 5,
      isFeatured: false,
    );

    setUp(() {
      fakeNewsRepo = FakeNewsRepository();
      fakeAgendaRepo = FakeAgendaRepository();
      fakePrayerRepo = FakePrayerRepository();
      viewModel = HomeViewModel(
        newsRepository: fakeNewsRepo,
        agendaRepository: fakeAgendaRepo,
        prayerRepository: fakePrayerRepo,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('initial state and navigation items are configured', () {
      expect(viewModel.slideIndex, equals(0));
      expect(viewModel.currentEventPage, equals(0));
      expect(viewModel.homeMenus.length, equals(8));
      expect(viewModel.homeMenus.map((m) => m['label']), contains('Berita'));
      expect(viewModel.homeMenus.map((m) => m['label']), contains('Agenda'));
    });

    test('loadLatestNews loads up to 4 latest news', () async {
      fakeNewsRepo.fakeLatest = [
        testNews1,
        testNews2,
        testNews1,
        testNews2,
        testNews1,
      ];

      await viewModel.loadLatestNews();

      expect(viewModel.newsLoading, isFalse);
      expect(viewModel.news.length, equals(4));
    });

    test('loadFeaturedNews filters only featured items', () async {
      fakeNewsRepo.fakeNews = [testNews1, testNews2];

      await viewModel.loadFeaturedNews();

      expect(viewModel.featuredLoading, isFalse);
      expect(viewModel.featuredNews.length, equals(1));
      expect(viewModel.featuredNews.first.title, equals('Berita A'));
      expect(viewModel.featuredNews.first.isFeatured, isTrue);
    });
  });
}
