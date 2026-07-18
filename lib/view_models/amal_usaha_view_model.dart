import 'package:flutter/foundation.dart';
import 'package:pdm_malang/models/amal_usaha_model.dart';
import 'package:pdm_malang/repositories/amal_usaha_repository.dart';

class AmalUsahaViewModel extends ChangeNotifier {
  final AmalUsahaRepository _repository;

  AmalUsahaViewModel({required AmalUsahaRepository repository})
      : _repository = repository;

  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedType = '';
  List<({String value, String label})> _availableTypes = [
    (value: '', label: 'Semua'),
  ];
  List<AmalUsahaItem> _items = [];
  bool _loading = true;
  String? _error;

  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  List<({String value, String label})> get availableTypes => _availableTypes;
  List<AmalUsahaItem> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  List<AmalUsahaItem> get filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.typeLabel.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setSearching(bool value) {
    _isSearching = value;
    if (!value) _searchQuery = '';
    notifyListeners();
  }

  void _updateAvailableTypes(List<AmalUsahaItem> data) {
    final Map<String, String> uniqueTypes = {};
    for (final item in data) {
      if (item.type.isNotEmpty && item.typeLabel.isNotEmpty) {
        uniqueTypes[item.type] = item.typeLabel;
      }
    }
    _availableTypes = [
      (value: '', label: 'Semua'),
      ...uniqueTypes.entries.map((e) => (value: e.key, label: e.value)).toList()
    ];
  }

  Future<void> initData() async {
    final cached = _repository.getCached(type: _selectedType.isEmpty ? null : _selectedType);
    if (cached != null) {
      _items = cached;
      _loading = false;
      _error = null;
      if (_selectedType.isEmpty) {
        _updateAvailableTypes(cached);
      }
      notifyListeners();
    } else {
      await loadData();
    }
  }

  Future<void> loadData() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getAmalUsaha(
      page: 1,
      perPage: 20,
      type: _selectedType.isEmpty ? null : _selectedType,
    );

    _loading = false;
    _items = result.data;
    _error = result.success ? null : (result.message.isNotEmpty ? result.message : 'Gagal memuat amal usaha');
    
    if (result.success && _selectedType.isEmpty) {
      _updateAvailableTypes(result.data);
    }
    notifyListeners();
  }

  Future<void> setType(String value) async {
    final cached = _repository.getCached(type: value.isEmpty ? null : value);
    if (cached != null) {
      _selectedType = value;
      _items = cached;
      _loading = false;
      _error = null;
      notifyListeners();
    } else {
      _selectedType = value;
      await loadData();
    }
  }

  void resetFilter() {
    _searchQuery = '';
    _selectedType = '';
    loadData();
  }

  Future<AmalUsahaItem?> getBySlug(String slug) async {
    return await _repository.getBySlug(slug);
  }
}
