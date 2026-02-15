import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../models/agenda_model.dart';
import '../models/news_model.dart';
import '../services/news_api_service.dart';
import '../services/event_api_service.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentEventPage = 0;
  int get currentEventPage => _currentEventPage;

  int _slideIndex = 0;
  int get slideIndex => _slideIndex;
  Timer? _slideTimer;

  final NewsApiService _newsApi = NewsApiService();
  final EventApiService _eventApi = EventApiService();
  List<NewsModel> _news = [];
  bool _newsLoading = true;
  List<AgendaModel> _events = [];
  bool _eventsLoading = true;

  List<NewsModel> get news => _news;
  bool get newsLoading => _newsLoading;
  List<AgendaModel> get events => _events;
  bool get eventsLoading => _eventsLoading;

  HomeViewModel() {
    _slideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final count = _news.isEmpty ? 1 : _news.length;
      _slideIndex = (_slideIndex + 1) % count;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    super.dispose();
  }

  /// Muat berita terbaru dari API untuk section Berita Terkini di Home.
  Future<void> loadLatestNews() async {
    _newsLoading = true;
    notifyListeners();
    try {
      final list = await _newsApi.getLatest();
      _news = list.length > 4 ? list.sublist(0, 4) : list;
    } catch (_) {
      _news = [];
    }
    _newsLoading = false;
    notifyListeners();
  }

  /// Muat agenda yang akan datang (terdekat di atas jam sekarang) untuk section Agenda Terkini di Home.
  /// Hanya acara yang belum lewat, diurut dari yang terdekat, maksimal 5.
  Future<void> loadUpcomingEvents() async {
    _eventsLoading = true;
    notifyListeners();
    try {
      List<AgendaModel> list = await _eventApi.getUpcoming();
      if (list.isEmpty) {
        final result = await _eventApi.getEvents(page: 1, perPage: 10);
        if (result.success && result.data.isNotEmpty) {
          list = result.data;
        }
      }
      final now = DateTime.now();
      final upcoming = list.where((e) {
        final dt = e.eventDateTime;
        return dt != null && dt.isAfter(now);
      }).toList();
      upcoming.sort((a, b) {
        final da = a.eventDateTime ?? DateTime(0);
        final db = b.eventDateTime ?? DateTime(0);
        return da.compareTo(db);
      });
      _events = upcoming.length > 5 ? upcoming.sublist(0, 5) : upcoming;
    } catch (_) {
      _events = [];
    }
    _eventsLoading = false;
    notifyListeners();
  }

  final List<Map<String, dynamic>> _homeMenus = [
    {'icon': RemixIcons.community_line, 'label': 'Profil'},
    {'icon': RemixIcons.article_line, 'label': 'Berita'},
    {'icon': RemixIcons.calendar_event_line, 'label': 'Agenda'},
    {'icon': RemixIcons.image_line, 'label': 'Dokumentasi'},
    {'icon': RemixIcons.notification_3_line, 'label': 'Pengumuman'},
    {'icon': RemixIcons.map_pin_line, 'label': 'Lokasi'},
    {'icon': RemixIcons.search_line, 'label': 'Cari'},
    {'icon': RemixIcons.share_line, 'label': 'Bagikan'},
  ];

  List<Map<String, dynamic>> get homeMenus => _homeMenus;

  void setEventPage(int index) {
    _currentEventPage = index;
    notifyListeners();
  }
}
