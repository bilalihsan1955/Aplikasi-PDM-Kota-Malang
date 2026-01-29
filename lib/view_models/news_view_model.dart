import 'package:flutter/material.dart';
import '../models/news_model.dart';

class NewsViewModel extends ChangeNotifier {
  String _selectedTag = 'Semua';
  String _searchQuery = '';
  bool _isSearching = false;

  String get selectedTag => _selectedTag;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  final List<String> categories = [
    'Semua',
    'News',
    'Event',
    'Info',
    'Update',
  ];

  final List<NewsModel> _allNews = [
    NewsModel(
      tag: 'News',
      time: '2 jam lalu',
      title: 'Kantor Cabang Baru Dibuka',
      desc: 'Peresmian kantor cabang baru...',
      image: 'assets/images/bg.webp',
    ),
    NewsModel(
      tag: 'Event',
      time: '5 jam lalu',
      title: 'Kajian Akbar Bulanan',
      desc: 'Kajian bersama tokoh nasional.',
      image: 'assets/images/profile.png',
    ),
    NewsModel(
      tag: 'Info',
      time: '1 hari lalu',
      title: 'Libur Nasional',
      desc: 'Penyesuaian jadwal kegiatan.',
      image: 'assets/images/bg.webp',
    ),
    NewsModel(
      tag: 'Update',
      time: '2 hari lalu',
      title: 'Pembaruan Sistem',
      desc: 'Optimalisasi performa.',
      image: 'assets/images/profile.png',
    ),
    NewsModel(
      tag: 'News',
      time: '3 jam lalu',
      title: 'Rapat Kerja Wilayah',
      desc: 'Koordinasi tahunan pengurus.',
      image: 'assets/images/bg.webp',
    ),
    NewsModel(
      tag: 'Info',
      time: '4 hari lalu',
      title: 'Update Keanggotaan',
      desc: 'Pendaftaran kartu anggota baru.',
      image: 'assets/images/profile.png',
    ),
  ];

  List<NewsModel> get filteredNews {
    return _allNews.where((item) {
      final matchTag = _selectedTag.toLowerCase() == 'semua' ||
          item.tag.toLowerCase() == _selectedTag.toLowerCase();
      final matchSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchTag && matchSearch;
    }).toList();
  }

  void setTag(String tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSearching(bool searching) {
    _isSearching = searching;
    if (!searching) _searchQuery = '';
    notifyListeners();
  }

  void resetFilters() {
    _selectedTag = 'Semua';
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }
}
