import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../utils/app_style.dart';
import '../widgets/back_button_app.dart';

/// Kategori untuk filter menu
const List<String> _categories = ['Semua', 'Layanan', 'Informasi', 'Lainnya'];

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key, this.openSearch = false});
  final bool openSearch;

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  late bool _isSearching;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _isSearching = widget.openSearch;
  }

  static const double _headerHeight = 160;

  void _setSearching(bool value) => setState(() => _isSearching = value);
  void _setSearchQuery(String value) => setState(() => _searchQuery = value);
  void _setCategory(String value) => setState(() => _selectedCategory = value);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/');
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              Positioned.fill(
                child: _MenuList(
                  searchQuery: _searchQuery,
                  selectedCategory: _selectedCategory,
                  headerHeight: _headerHeight,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _CombinedHeader(
                  isSearching: _isSearching,
                  searchQuery: _searchQuery,
                  onSearchingChanged: _setSearching,
                  onSearchQueryChanged: _setSearchQuery,
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: _setCategory,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CombinedHeader extends StatelessWidget {
  final bool isSearching;
  final String searchQuery;
  final ValueChanged<bool> onSearchingChanged;
  final ValueChanged<String> onSearchQueryChanged;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const _CombinedHeader({
    required this.isSearching,
    required this.searchQuery,
    required this.onSearchingChanged,
    required this.onSearchQueryChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isSearching
                    ? Hero(
                        tag: 'menu_search',
                        child: Material(
                          color: Colors.transparent,
                          child: _SearchBar(
                            searchQuery: searchQuery,
                            onQueryChanged: onSearchQueryChanged,
                            onClose: () => onSearchingChanged(false),
                          ),
                        ),
                      )
                    : _HeaderTitle(onSearchTap: () => onSearchingChanged(true)),
              ),
            ),
            const SizedBox(height: 16),
            _CategoryChips(
              selectedCategory: selectedCategory,
              onCategoryChanged: onCategoryChanged,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  final VoidCallback onSearchTap;

  const _HeaderTitle({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      key: const ValueKey('headerTitle'),
      children: [
        BackButtonApp(onTap: () => context.go('/')),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Akses cepat layanan dan informasi',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onSearchTap,
          icon: Icon(
            RemixIcons.search_line,
            size: 28,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClose;

  const _SearchBar({
    required this.searchQuery,
    required this.onQueryChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const ValueKey('searchField'),
      height: 50,
      padding: const EdgeInsets.only(left: 12, right: 0),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(RemixIcons.search_line, color: Colors.grey, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              autofocus: true,
              onChanged: onQueryChanged,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: 'Cari menu...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(RemixIcons.close_line, size: 20, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const _CategoryChips({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isActive = category == selectedCategory;

          return GestureDetector(
            onTap: () => onCategoryChanged(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF152D8D)
                    : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF6F7FB)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;
  final double headerHeight;

  const _MenuList({
    required this.searchQuery,
    required this.selectedCategory,
    required this.headerHeight,
  });

  static List<_MenuItemData> _buildAllItems(BuildContext context) {
    return [
      _MenuItemData(RemixIcons.community_line, 'Profil Organisasi', 'Layanan', () => context.push('/about-pdm')),
      _MenuItemData(RemixIcons.article_line, 'Berita & Pengumuman', 'Layanan', () => context.go('/berita')),
      _MenuItemData(RemixIcons.calendar_event_line, 'Agenda Kegiatan', 'Layanan', () => context.go('/agenda')),
      _MenuItemData(RemixIcons.image_line, 'Dokumentasi', 'Layanan', () => context.push('/gallery')),
      _MenuItemData(RemixIcons.notification_3_line, 'Pengumuman', 'Layanan', () => context.push('/notifications')),
      _MenuItemData(RemixIcons.map_pin_line, 'Lokasi Kantor', 'Informasi', () => context.push('/placeholder', extra: 'Lokasi Kantor')),
      _MenuItemData(RemixIcons.search_line, 'Cari', 'Lainnya', () => context.push('/placeholder', extra: 'Cari')),
      _MenuItemData(RemixIcons.share_line, 'Bagikan', 'Lainnya', () => context.push('/placeholder', extra: 'Bagikan')),
    ];
  }

  List<_MenuItemData> _filterItems(BuildContext context) {
    var list = _buildAllItems(context);
    if (selectedCategory != 'Semua') {
      list = list.where((e) => e.category == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((e) => e.title.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + headerHeight;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 24;
    final items = _filterItems(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                RemixIcons.search_line,
                size: 80,
                color: isDark ? Colors.white24 : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Menu tidak ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba ubah kata kunci atau kategori',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        top: topPadding,
        left: 24,
        right: 24,
        bottom: bottomPadding,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return _MenuCard(
          icon: item.icon,
          title: item.title,
          category: item.category,
          onTap: item.onTap,
        );
      },
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String category;
  final VoidCallback onTap;

  _MenuItemData(this.icon, this.title, this.category, this.onTap);
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String category;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF152D8D) : const Color(0xFFE0E6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isDark ? Colors.white : AppStyle.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A202C),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                RemixIcons.arrow_right_s_line,
                color: Colors.grey[isDark ? 600 : 300],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
