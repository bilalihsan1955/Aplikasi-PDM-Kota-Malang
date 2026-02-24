import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pdm_malang/models/amal_usaha_model.dart';
import 'package:pdm_malang/services/amal_usaha_api_service.dart';
import '../widgets/back_button_app.dart';

/// Filter type API: pendidikan, kesehatan, sosial, ekonomi. Null = semua.
const List<({String value, String label})> kAmalUsahaTypes = [
  (value: '', label: 'Semua'),
  (value: 'pendidikan', label: 'Pendidikan'),
  (value: 'kesehatan', label: 'Kesehatan'),
  (value: 'sosial', label: 'Sosial'),
  (value: 'ekonomi', label: 'Ekonomi'),
];

class AmalUsahaPage extends StatefulWidget {
  const AmalUsahaPage({super.key});

  @override
  State<AmalUsahaPage> createState() => _AmalUsahaPageState();
}

class _AmalUsahaPageState extends State<AmalUsahaPage> {
  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedType = '';
  List<AmalUsahaItem> _items = [];
  bool _loading = true;
  String? _error;

  void _setSearching(bool value) => setState(() => _isSearching = value);
  void _setSearchQuery(String value) => setState(() => _searchQuery = value);

  @override
  void initState() {
    super.initState();
    final cached = AmalUsahaApiService.getCached(type: _selectedType.isEmpty ? null : _selectedType);
    if (cached != null) {
      setState(() {
        _items = cached;
        _loading = false;
        _error = null;
      });
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await AmalUsahaApiService().getAmalUsaha(
      page: 1,
      perPage: 20,
      type: _selectedType.isEmpty ? null : _selectedType,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _items = result.data;
      _error = result.success ? null : (result.message.isNotEmpty ? result.message : 'Gagal memuat amal usaha');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: _CombinedHeader(
            isSearching: _isSearching,
            selectedType: _selectedType,
            loading: _loading,
            onSearchChanged: _setSearchQuery,
            onToggleSearch: _setSearching,
            onTypeSelected: (value) {
              final cached = AmalUsahaApiService.getCached(type: value.isEmpty ? null : value);
              if (cached != null) {
                setState(() {
                  _selectedType = value;
                  _items = cached;
                  _loading = false;
                  _error = null;
                });
              } else {
                setState(() => _selectedType = value);
                _loadData();
              }
            },
          ),
        ),
        body: _AmalUsahaList(
          items: _items,
          searchQuery: _searchQuery,
          loading: _loading,
          error: _error,
          onRetry: _loadData,
        ),
      ),
    );
  }
}

class _TypeFilter extends StatelessWidget {
  static const List<String> _skeletonLabels = ['Semua', 'Pendidikan', 'Kesehatan', 'Sosial', 'Ekonomi'];

  final String selectedType;
  final bool loading;
  final ValueChanged<String> onSelected;

  const _TypeFilter({
    required this.selectedType,
    required this.loading,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: loading
          ? Skeletonizer(
              enabled: true,
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _skeletonLabels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _skeletonLabels[index],
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            )
          : ListView.separated(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: kAmalUsahaTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final t = kAmalUsahaTypes[index];
                final isActive = selectedType == t.value;
                return GestureDetector(
                  onTap: () => onSelected(t.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF152D8D)
                          : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF6F7FB)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _CombinedHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final String selectedType;
  final bool loading;
  final Function(String) onSearchChanged;
  final Function(bool) onToggleSearch;
  final ValueChanged<String> onTypeSelected;

  const _CombinedHeader({
    required this.isSearching,
    required this.selectedType,
    required this.loading,
    required this.onSearchChanged,
    required this.onToggleSearch,
    required this.onTypeSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(160);

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
            const SizedBox(height: 8),
            _AnimatedHeader(
              isSearching: isSearching,
              onSearchChanged: onSearchChanged,
              onToggleSearch: onToggleSearch,
            ),
            const SizedBox(height: 16),
            _TypeFilter(
              selectedType: selectedType,
              loading: loading,
              onSelected: onTypeSelected,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AnimatedHeader extends StatelessWidget {
  final bool isSearching;
  final Function(String) onSearchChanged;
  final Function(bool) onToggleSearch;

  const _AnimatedHeader({
    required this.isSearching,
    required this.onSearchChanged,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isSearching
            ? _SearchBar(onSearchChanged: onSearchChanged, onToggleSearch: onToggleSearch)
            : _HeaderTitle(onToggleSearch: onToggleSearch),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  final Function(bool) onToggleSearch;

  const _HeaderTitle({required this.onToggleSearch});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      key: const ValueKey('headerTitle'),
      children: [
        BackButtonApp(onTap: () => context.pop()),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Amal Usaha',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Unit-unit usaha Muhammadiyah',
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
          onPressed: () => onToggleSearch(true),
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
  final Function(String) onSearchChanged;
  final Function(bool) onToggleSearch;

  const _SearchBar({required this.onSearchChanged, required this.onToggleSearch});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const ValueKey('searchField'),
      height: 50,
      padding: const EdgeInsets.only(left: 12),
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
              onChanged: onSearchChanged,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari amal usaha...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: () => onToggleSearch(false),
            icon: const Icon(RemixIcons.close_line, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _AmalUsahaList extends StatelessWidget {
  final List<AmalUsahaItem> items;
  final String searchQuery;
  final bool loading;
  final String? error;
  final Future<void> Function()? onRetry;

  const _AmalUsahaList({
    required this.items,
    required this.searchQuery,
    required this.loading,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (loading) {
      return RefreshIndicator(
        onRefresh: () async {
          if (onRetry != null) await onRetry!();
        },
        displacement: 40,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              sliver: SliverSafeArea(
                top: false,
                sliver: Skeletonizer.sliver(
                  enabled: true,
                  child: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const _AmalUsahaCardSkeleton(),
                      childCount: 6,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (error != null && error!.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          if (onRetry != null) await onRetry!();
        },
        displacement: 40,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RemixIcons.wifi_off_line, size: 56, color: isDark ? Colors.white24 : Colors.grey[300]),
                      const SizedBox(height: 20),
                      Text('Oops!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2D3142))),
                      const SizedBox(height: 8),
                      Text(error!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.white60 : Colors.grey[600])),
                      const SizedBox(height: 24),
                      if (onRetry != null)
                        GestureDetector(
                          onTap: () => onRetry!(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            decoration: BoxDecoration(color: const Color(0xFF152D8D), borderRadius: BorderRadius.circular(24)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [Icon(RemixIcons.refresh_line, size: 18, color: Colors.white), SizedBox(width: 8), Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final query = searchQuery.trim().toLowerCase();
    final filteredItems = query.isEmpty
        ? items
        : items.where((item) {
            return item.name.toLowerCase().contains(query) ||
                item.description.toLowerCase().contains(query) ||
                item.typeLabel.toLowerCase().contains(query);
          }).toList();

    if (filteredItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          if (onRetry != null) await onRetry!();
        },
        displacement: 40,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  searchQuery.isEmpty ? 'Belum ada data amal usaha' : 'Tidak ditemukan',
                  style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (onRetry != null) await onRetry!();
      },
      displacement: 40,
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            sliver: SliverSafeArea(
              top: false,
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredItems[index];
                    return _AmalUsahaCard(item: item);
                  },
                  childCount: filteredItems.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmalUsahaCardSkeleton extends StatelessWidget {
  const _AmalUsahaCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Container(color: Colors.grey[300])),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              color: Colors.grey[400],
              child: const Text('Nama amal usaha placeholder', maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _amalUsahaPlaceholderImage(bool isDark) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    color: isDark ? Colors.white12 : Colors.grey[300],
    child: Icon(RemixIcons.building_2_line, size: 48, color: Colors.grey[600]),
  );
}

class _AmalUsahaCard extends StatelessWidget {
  final AmalUsahaItem item;

  const _AmalUsahaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasNetworkImage = item.image.isNotEmpty && item.image.startsWith('http');

    return GestureDetector(
      onTap: () => context.push('/amal-usaha/detail', extra: item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasNetworkImage
                  ? Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Skeletonizer(
                          enabled: true,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: isDark ? Colors.white12 : Colors.grey[300],
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _amalUsahaPlaceholderImage(isDark),
                    )
                  : _amalUsahaPlaceholderImage(isDark),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

