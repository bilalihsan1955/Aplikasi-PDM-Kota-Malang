import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/news_model.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentEventPage = 0;
  int get currentEventPage => _currentEventPage;

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

  final List<NewsModel> _news = [
    NewsModel(
      tag: "POLICY",
      time: "2 hours ago",
      title: "New Remote Work Policy",
      desc: "Updating hybrid work guidelines for flexibility.",
      image: "assets/images/profile.png",
    ),
    NewsModel(
      tag: "EVENT",
      time: "5 hours ago",
      title: "Annual Tech Conference",
      desc: "Join us for the biggest tech event of the year.",
      image: "assets/images/bg.webp",
    ),
    NewsModel(
      tag: "NEWS",
      time: "2 days ago",
      title: "New Office Opening",
      desc: "We are expanding to a new location in Bali.",
      image: "assets/images/bg.webp",
    ),
    NewsModel(
      tag: "UPDATE",
      time: "1 day ago",
      title: "System Maintenance",
      desc: "Server downtime scheduled for this weekend.",
      image: "assets/images/profile.png",
    ),
  ];

  final List<Map<String, dynamic>> _homeMenus = [
    {'icon': Icons.apartment, 'label': 'Profil'},
    {'icon': Icons.article_outlined, 'label': 'Berita'},
    {'icon': Icons.event_outlined, 'label': 'Agenda'},
    {'icon': Icons.photo_library_outlined, 'label': 'Dokumentasi'},
    {'icon': Icons.notifications_none, 'label': 'Pengumuman'},
    {'icon': Icons.location_on_outlined, 'label': 'Lokasi'},
    {'icon': Icons.search, 'label': 'Cari'},
    {'icon': Icons.share_outlined, 'label': 'Bagikan'},
  ];

  List<EventModel> get events => _events;
  List<NewsModel> get news => _news;
  List<Map<String, dynamic>> get homeMenus => _homeMenus;

  void setEventPage(int index) {
    _currentEventPage = index;
    notifyListeners();
  }
}
