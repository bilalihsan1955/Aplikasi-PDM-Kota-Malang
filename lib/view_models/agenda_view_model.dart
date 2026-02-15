import 'package:flutter/material.dart';
import 'package:pdm_malang/models/agenda_model.dart';
import 'package:pdm_malang/services/event_api_service.dart';

class AgendaViewModel extends ChangeNotifier {
  final EventApiService _api = EventApiService();

  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isLoading = true;
  String _errorMessage = '';

  List<AgendaModel> _allAgendas = [];
  int _currentPage = 1;
  static const int _perPage = 15;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  /// Filter chip: "Semua" + nama kategori unik dari data.
  List<String> get timeFilters {
    final names = <String>{};
    for (final a in _allAgendas) {
      if (a.categoryName.isNotEmpty && a.categoryName != 'Agenda') {
        names.add(a.categoryName);
      }
    }
    final list = names.toList()..sort();
    return ['Semua', ...list];
  }

  /// Daftar agenda setelah filter + search (client-side).
  List<AgendaModel> get filteredAgendas {
    return _allAgendas.where((item) {
      final matchFilter = _selectedFilter == 'Semua' ||
          item.categoryName.toLowerCase() == _selectedFilter.toLowerCase();
      final matchSearch = _searchQuery.trim().isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  /// Set loading + kosongkan list agar UI langsung tampil skeleton (dipanggil sebelum load).
  void beginLoad() {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = '';
    _allAgendas = [];
    notifyListeners();
  }

  /// Muat halaman pertama (refresh). List dikosongkan dulu agar UI tampil skeleton.
  Future<void> loadEvents({int? categoryId, String? status}) async {
    _isLoading = true;
    _errorMessage = '';
    _allAgendas = [];
    notifyListeners();

    final result = await _api.getEvents(
      page: 1,
      perPage: _perPage,
      categoryId: categoryId,
      status: status,
    );

    _isLoading = false;
    if (result.success) {
      _allAgendas = result.data;
      _currentPage = 1;
      _hasMore = result.data.length >= _perPage;
    } else {
      _errorMessage = result.message.isNotEmpty ? result.message : 'Gagal memuat agenda';
      _allAgendas = [];
    }
    notifyListeners();
  }

  /// Muat halaman berikutnya.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();

    final result = await _api.getEvents(
      page: _currentPage + 1,
      perPage: _perPage,
    );

    _isLoadingMore = false;
    if (result.success && result.data.isNotEmpty) {
      _allAgendas = [..._allAgendas, ...result.data];
      _currentPage++;
      _hasMore = result.data.length >= _perPage;
    } else {
      _hasMore = false;
    }
    notifyListeners();
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

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
