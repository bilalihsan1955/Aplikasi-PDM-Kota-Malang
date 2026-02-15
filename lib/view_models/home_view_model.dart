import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../models/event_model.dart';
import '../models/news_model.dart';
import '../services/news_api_service.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentEventPage = 0;
  int get currentEventPage => _currentEventPage;

  int _slideIndex = 0;
  int get slideIndex => _slideIndex;
  static const int slideCount = 3;
  Timer? _slideTimer;

  final NewsApiService _newsApi = NewsApiService();
  List<NewsModel> _news = [];
  bool _newsLoading = true;

  List<NewsModel> get news => _news;
  bool get newsLoading => _newsLoading;

  HomeViewModel() {
    _slideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _slideIndex = (_slideIndex + 1) % slideCount;
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

  final List<EventModel> _events = [
    EventModel(
      month: "OCT",
      date: "24",
      title: "Kajian Tablogh Akbar",
      time: "10:00 AM",
      location: "Aula PDM Kota Malang",
    ),
    EventModel(
      month: "NOV",
      date: "12",
      title: "Design Sprint",
      time: "01:00 PM",
      location: "Meeting Room A",
    ),
    EventModel(
      month: "DEC",
      date: "05",
      title: "Year End Party",
      time: "07:00 PM",
      location: "Grand Ballroom",
    ),
  ];

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

  List<EventModel> get events => _events;
  List<Map<String, dynamic>> get homeMenus => _homeMenus;

  void setEventPage(int index) {
    _currentEventPage = index;
    notifyListeners();
  }
}
