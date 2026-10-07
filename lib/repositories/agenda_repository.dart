import 'package:pdm_malang/models/agenda_model.dart';
import 'package:pdm_malang/services/api/event_api_service.dart';
import 'package:pdm_malang/utils/network_error_mapper.dart';

class AgendaRepository {
  final EventApiService _apiService;

  AgendaRepository({required EventApiService apiService})
      : _apiService = apiService;

  Future<EventListResult> getEvents({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? status,
  }) async {
    return await _apiService.getEvents(
      page: page,
      perPage: perPage,
      categoryId: categoryId,
      status: status,
    );
  }

  Future<List<AgendaModel>> getUpcomingEvents() async {
    return await _apiService.getUpcoming();
  }

  Future<AgendaModel?> getAgendaBySlug(String slug) async {
    return await _apiService.getBySlug(slug);
  }

  String getFriendlyError(String raw) =>
      NetworkErrorMapper.toFriendly(raw, fallbackContext: 'agenda');
}
