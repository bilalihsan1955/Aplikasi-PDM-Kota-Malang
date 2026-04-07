import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:remixicon/remixicon.dart';
import '../models/agenda_model.dart';
import '../models/news_model.dart';
import '../services/news_api_service.dart';
import '../services/event_api_service.dart';
import '../services/fcm_service.dart';
import '../services/prayer_time_service.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentEventPage = 0;
  int get currentEventPage => _currentEventPage;

  int _slideIndex = 0;
  int get slideIndex => _slideIndex;
  Timer? _slideTimer;
  Timer? _midnightPrayerRefreshTimer;
  String? _lastPrayerSyncDayKey;

  final NewsApiService _newsApi = NewsApiService();
  final EventApiService _eventApi = EventApiService();
  List<NewsModel> _news = [];
  bool _newsLoading = true;
  List<NewsModel> _featuredNews = [];
  bool _featuredLoading = true;
  List<AgendaModel> _events = [];
  bool _eventsLoading = true;

  final PrayerTimeService _prayerApi = PrayerTimeService();
  PrayerTimeResult? _prayerTime;
  double? _qiblaDirection;
  bool _prayerLoading = true;

  List<NewsModel> get news => _news;
  bool get newsLoading => _newsLoading;
  List<NewsModel> get featuredNews => _featuredNews;
  bool get featuredLoading => _featuredLoading;
  List<AgendaModel> get events => _events;
  bool get eventsLoading => _eventsLoading;
  PrayerTimeResult? get prayerTime => _prayerTime;
  double? get qiblaDirection => _qiblaDirection;
  bool get prayerLoading => _prayerLoading;

  HomeViewModel() {
    _slideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final count = _featuredNews.isEmpty ? 1 : _featuredNews.length;
      _slideIndex = (_slideIndex + 1) % count;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _midnightPrayerRefreshTimer?.cancel();
    super.dispose();
  }

  String _todayKey() {
    final n = DateTime.now();
    final y = n.year.toString().padLeft(4, '0');
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _scheduleMidnightPrayerRefresh() {
    _midnightPrayerRefreshTimer?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1, 0, 1);
    final wait = next.difference(now);
    _midnightPrayerRefreshTimer = Timer(wait, () {
      unawaited(loadPrayerData());
    });
  }

  Future<void> refreshPrayerDataIfStaleOnResume() async {
    final today = _todayKey();
    if (_lastPrayerSyncDayKey != today) {
      await loadPrayerData();
      return;
    }
    if (_midnightPrayerRefreshTimer == null ||
        !_midnightPrayerRefreshTimer!.isActive) {
      _scheduleMidnightPrayerRefresh();
    }
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

  /// Muat berita featured (is_featured: true) untuk banner/slide di Home.
  Future<void> loadFeaturedNews() async {
    _featuredLoading = true;
    notifyListeners();
    try {
      final result = await _newsApi.getNews(page: 1, perPage: 10);
      if (result.success) {
        _featuredNews = result.data.where((n) => n.isFeatured).toList();
      } else {
        _featuredNews = [];
      }
    } catch (_) {
      _featuredNews = [];
    }
    _featuredLoading = false;
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
    {'icon': RemixIcons.home_heart_line, 'label': 'sholat'},
    {'icon': RemixIcons.community_line, 'label': 'Profil'},
    {'icon': RemixIcons.article_line, 'label': 'Berita'},
    {'icon': RemixIcons.calendar_event_line, 'label': 'Agenda'},
    {'icon': RemixIcons.building_2_line, 'label': 'Amal Usaha'},
    {'icon': RemixIcons.image_line, 'label': 'Dokumentasi'},
    {'icon': RemixIcons.calendar_2_line, 'label': 'KHGT'},
    {'icon': RemixIcons.search_line, 'label': 'Cari'},
  ];

  List<Map<String, dynamic>> get homeMenus => _homeMenus;

  /// Muat waktu sholat dan arah kiblat. Nama kota dari API waktu sholat (/location by lat/lng).
  Future<void> loadPrayerData() async {
    _prayerLoading = true;
    notifyListeners();
    try {
      final position = await _prayerApi.getCurrentPosition();
      final lat = position?.latitude;
      final lng = position?.longitude;

      final results = await Future.wait([
        _prayerApi.getTodayPrayerTimes(lat: lat, lng: lng, useDeviceLocation: false),
        _prayerApi.getQiblaDirection(lat: lat, lng: lng),
      ]);
      final prayer = results[0] as PrayerTimeResult?;
      _prayerTime = prayer;
      _qiblaDirection = results[1] as double?;
      if (prayer != null) {
        _lastPrayerSyncDayKey = _todayKey();
        _scheduleMidnightPrayerRefresh();
        unawaited(
          FCMService().syncPrayerScheduleNotifications(
            city: prayer.city,
            prayers: [
              ('Subuh', prayer.fajr),
              ('Dzuhur', prayer.dhuhr),
              ('Ashar', prayer.asr),
              ('Maghrib', prayer.maghrib),
              ('Isya', prayer.isha),
            ],
          ),
        );
      }
    } catch (_) {}
    _prayerLoading = false;
    notifyListeners();
  }

  void setEventPage(int index) {
    _currentEventPage = index;
    notifyListeners();
  }

  /// Refresh semua data Home: kosongkan data & tampilkan skeleton semua section,
  /// lalu GET berurutan satu per satu.
  Future<void> refreshAll() async {
    _featuredNews = [];
    _events = [];
    _news = [];
    _prayerTime = null;
    _qiblaDirection = null;
    _featuredLoading = true;
    _eventsLoading = true;
    _newsLoading = true;
    _prayerLoading = true;
    _slideIndex = 0;
    notifyListeners();

    await loadFeaturedNews();
    await loadUpcomingEvents();
    await loadPrayerData();
    await loadLatestNews();
  }
}
