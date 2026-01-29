import 'package:flutter/material.dart';
import '../models/agenda_model.dart';

class AgendaViewModel extends ChangeNotifier {
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  bool _isSearching = false;

  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  final List<String> timeFilters = [
    'Semua',
    'Minggu Ini',
    'Bulan Ini',
    'Akan Datang',
  ];

  final List<AgendaModel> _allAgendas = [
    AgendaModel(
      title: 'Rapat Evaluasi Bulanan',
      location: 'Ruang Meeting Lt. 2',
      date: '28',
      month: 'JAN',
      time: '09:00 - 11:00 WIB',
      category: 'Minggu Ini',
    ),
    AgendaModel(
      title: 'Workshop Public Speaking',
      location: 'Aula Utama',
      date: '02',
      month: 'FEB',
      time: '13:00 - 16:00 WIB',
      category: 'Minggu Ini',
    ),
    AgendaModel(
      title: 'Kunjungan Industri',
      location: 'PT. Teknologi Maju',
      date: '15',
      month: 'FEB',
      time: '08:00 - 15:00 WIB',
      category: 'Bulan Ini',
    ),
    AgendaModel(
      title: 'Gathering Nasional',
      location: 'Hotel Grand Asia',
      date: '10',
      month: 'MAR',
      time: '08:00 - 20:00 WIB',
      category: 'Akan Datang',
    ),
  ];

  List<AgendaModel> get filteredAgendas {
    return _allAgendas.where((item) {
      final matchTag = _selectedFilter == 'Semua' || item.category == _selectedFilter;
      final matchSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchTag && matchSearch;
    }).toList();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
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
    _selectedFilter = 'Semua';
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }
}
