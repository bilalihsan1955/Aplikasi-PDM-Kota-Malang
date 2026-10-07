import 'package:flutter_test/flutter_test.dart';
import 'package:pdm_malang/models/agenda_model.dart';
import 'package:pdm_malang/repositories/agenda_repository.dart';
import 'package:pdm_malang/services/api/event_api_service.dart';
import 'package:pdm_malang/utils/network_error_mapper.dart';
import 'package:pdm_malang/view_models/agenda_view_model.dart';

class FakeAgendaRepository implements AgendaRepository {
  List<AgendaModel> fakeAgendas = [];
  bool shouldSucceed = true;
  String errorMessage = 'Failed to load';

  @override
  Future<EventListResult> getEvents({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? status,
  }) async {
    if (!shouldSucceed) {
      return EventListResult(
        success: false,
        message: errorMessage,
        data: const [],
      );
    }
    return EventListResult(
      success: true,
      message: 'OK',
      data: fakeAgendas,
    );
  }

  @override
  Future<List<AgendaModel>> getUpcomingEvents() async => [];

  @override
  Future<AgendaModel?> getAgendaBySlug(String slug) async => null;

  @override
  String getFriendlyError(String raw) =>
      NetworkErrorMapper.toFriendly(raw, fallbackContext: 'agenda');
}

void main() {
  group('AgendaViewModel Tests', () {
    late FakeAgendaRepository fakeRepo;
    late AgendaViewModel viewModel;

    final sampleAgenda1 = AgendaModel(
      id: 1,
      title: 'Musyawarah Daerah Muhammadiyah',
      slug: 'musyda-malang',
      description: 'Musyda pimpinan daerah kota Malang',
      image: 'https://example.com/musyda.jpg',
      eventDate: '2026-11-20',
      eventTime: '08:00',
      location: 'Aula PDM Malang',
      status: 'upcoming',
      category: EventCategory(id: 1, name: 'Organisasi', slug: 'organisasi'),
    );

    final sampleAgenda2 = AgendaModel(
      id: 2,
      title: 'Bakti Sosial Ramadhan',
      slug: 'baksos-ramadhan',
      description: 'Pembagian sembako dhuafa',
      image: 'https://example.com/baksos.jpg',
      eventDate: '2026-11-25',
      eventTime: '09:00',
      location: 'Masjid Al-Ikhlas',
      status: 'upcoming',
      category: EventCategory(id: 2, name: 'Sosial', slug: 'sosial'),
    );

    setUp(() {
      fakeRepo = FakeAgendaRepository();
      viewModel = AgendaViewModel(repository: fakeRepo);
    });

    test('initial state is correct', () {
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.selectedFilter, equals('Semua'));
      expect(viewModel.searchQuery, isEmpty);
      expect(viewModel.errorMessage, isEmpty);
      expect(viewModel.filteredAgendas, isEmpty);
      expect(viewModel.timeFilters, equals(['Semua']));
    });

    test('loadEvents successfully updates agendas and categories', () async {
      fakeRepo.fakeAgendas = [sampleAgenda1, sampleAgenda2];
      fakeRepo.shouldSucceed = true;

      await viewModel.loadEvents();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isEmpty);
      expect(viewModel.filteredAgendas.length, equals(2));
      expect(viewModel.timeFilters, containsAll(['Semua', 'Organisasi', 'Sosial']));
    });

    test('filteredAgendas filters by category and search keyword', () async {
      fakeRepo.fakeAgendas = [sampleAgenda1, sampleAgenda2];
      await viewModel.loadEvents();

      viewModel.setFilter('Organisasi');
      expect(viewModel.selectedFilter, equals('Organisasi'));
      expect(viewModel.filteredAgendas.length, equals(1));
      expect(viewModel.filteredAgendas.first.title, equals('Musyawarah Daerah Muhammadiyah'));

      viewModel.resetFilters();
      viewModel.setSearchQuery('sembako');
      expect(viewModel.filteredAgendas.length, equals(1));
      expect(viewModel.filteredAgendas.first.slug, equals('baksos-ramadhan'));
    });

    test('loadEvents sets friendly error message on connection error', () async {
      fakeRepo.shouldSucceed = false;
      fakeRepo.errorMessage = 'ClientException with SocketException';

      await viewModel.loadEvents();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.filteredAgendas, isEmpty);
      expect(viewModel.errorMessage, contains('Koneksi internet'));
    });
  });
}
