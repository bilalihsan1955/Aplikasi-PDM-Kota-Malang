import 'package:flutter/material.dart';
import 'package:pdm_malang/models/news_model.dart';
import 'package:pdm_malang/services/news_api_service.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsApiService _api = NewsApiService();

  String _selectedTag = 'Semua';
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isLoading = true;
  String _errorMessage = '';

  List<NewsModel> _allNews = [];
  int _currentPage = 1;
  static const int _perPage = 15;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  String get selectedTag => _selectedTag;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  /// Kategori: "Semua" + nama unik dari berita yang sudah dimuat.
  List<String> get categories {
    final names = <String>{};
    for (final n in _allNews) {
      if (n.category != null && n.category!.name.isNotEmpty) {
        names.add(n.category!.name);
      }
    }
    final list = names.toList()..sort();
    return ['Semua', ...list];
  }

  /// Daftar berita setelah filter tag + search (client-side).
  List<NewsModel> get filteredNews {
    return _allNews.where((item) {
      final matchTag = _selectedTag == 'Semua' ||
          (item.category?.name ?? '').toLowerCase() == _selectedTag.toLowerCase();
      final matchSearch = _searchQuery.trim().isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.excerpt.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchTag && matchSearch;
    }).toList();
  }

  /// Set loading + kosongkan list agar UI langsung tampil skeleton (dipanggil sebelum load).
  void beginLoad() {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = '';
    _allNews = [];
    notifyListeners();
  }

  /// Muat halaman pertama (refresh). Saat dipanggil, list dikosongkan dulu
  /// agar UI menampilkan skeleton seperti load pertama kali.
  Future<void> loadNews({int? categoryId, String? search}) async {
    _isLoading = true;
    _errorMessage = '';
    _allNews = [];
    notifyListeners();

    final result = await _api.getNews(
      page: 1,
      perPage: _perPage,
      categoryId: categoryId,
      search: search?.trim().isEmpty ?? true ? null : search,
    );

    _isLoading = false;
    if (result.success) {
      _allNews = result.data;
      _currentPage = 1;
      _hasMore = result.data.length >= _perPage;
    } else {
      _errorMessage = _friendlyError(result.message);
      _allNews = [];
    }
    notifyListeners();
  }

  static String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('unreachable') ||
        lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('no internet') ||
        lower.contains('failed host lookup')) {
      return 'Koneksi internet tidak stabil.\nPeriksa jaringan Anda dan coba lagi.';
    }
    if (lower.contains('404') || lower.contains('not found')) {
      return 'Data tidak ditemukan.\nSilakan coba lagi nanti.';
    }
    if (lower.contains('500') || lower.contains('internal server')) {
      return 'Server sedang bermasalah.\nSilakan coba beberapa saat lagi.';
    }
    if (lower.contains('403') || lower.contains('forbidden') || lower.contains('unauthorized')) {
      return 'Akses ditolak.\nSilakan login ulang atau hubungi admin.';
    }
    if (raw.isEmpty) return 'Gagal memuat berita.\nSilakan coba lagi.';
    return 'Terjadi kesalahan.\nSilakan coba lagi nanti.';
  }

  /// Muat halaman berikutnya (pagination).
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();

    final result = await _api.getNews(
      page: _currentPage + 1,
      perPage: _perPage,
    );

    _isLoadingMore = false;
    if (result.success && result.data.isNotEmpty) {
      _allNews = [..._allNews, ...result.data];
      _currentPage++;
      _hasMore = result.data.length >= _perPage;
    } else {
      _hasMore = false;
    }
    notifyListeners();
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

  /// Bersihkan error (mis. setelah user tutup snackbar).
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
