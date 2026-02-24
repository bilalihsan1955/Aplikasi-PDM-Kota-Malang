import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pdm_malang/models/gallery_model.dart';
import 'package:pdm_malang/services/gallery_api_service.dart';
import 'empty_placeholder_page.dart';
import '../widgets/back_button_app.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _isSearching = false;
  String _searchQuery = '';
  List<GalleryModel> _items = [];
  bool _loading = true;
  String? _error;

  void _setSearchQuery(String value) => setState(() => _searchQuery = value);

  @override
  void initState() {
    super.initState();
    final cached = GalleryApiService.getCached();
    if (cached != null) {
      setState(() {
        _items = cached;
        _loading = false;
        _error = null;
      });
    } else {
      _loadGallery();
    }
  }

  Future<void> _loadGallery() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await GalleryApiService().getGallery();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _items = result.data;
      _error = result.success ? null : (result.message.isNotEmpty ? result.message : 'Gagal memuat galeri');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: _CombinedHeader(
            isSearching: _isSearching,
            onSearchChanged: _setSearchQuery,
            onToggleSearch: (value) {
              setState(() {
                _isSearching = value;
                if (!value) _searchQuery = '';
              });
            },
          ),
        ),
        body: _GalleryList(
          items: _items,
          searchQuery: _searchQuery,
          loading: _loading,
          error: _error,
          onRetry: _loadGallery,
          onResetFilter: () => setState(() => _searchQuery = ''),
        ),
      ),
    );
  }
}

class _CombinedHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final Function(String) onSearchChanged;
  final Function(bool) onToggleSearch;

  const _CombinedHeader({
    required this.isSearching,
    required this.onSearchChanged,
    required this.onToggleSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(110);

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
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Galeri',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2D3142),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dokumentasi kegiatan',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
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
                hintText: 'Cari dokumentasi...',
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

class _GalleryList extends StatelessWidget {
  final List<GalleryModel> items;
  final String searchQuery;
  final bool loading;
  final String? error;
  final Future<void> Function()? onRetry;
  final VoidCallback? onResetFilter;

  const _GalleryList({
    required this.items,
    required this.searchQuery,
    required this.loading,
    this.error,
    this.onRetry,
    this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (loading) {
      return RefreshIndicator(
        onRefresh: () async { if (onRetry != null) await onRetry!(); },
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
                      (context, index) => const _GalleryCardSkeleton(),
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
        onRefresh: () async { if (onRetry != null) await onRetry!(); },
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
            return item.title.toLowerCase().contains(query) ||
                item.description.toLowerCase().contains(query);
          }).toList();

    if (filteredItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async { if (onRetry != null) await onRetry!(); },
        displacement: 40,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptySearchStateWidget(
                title: searchQuery.isEmpty ? 'Belum ada dokumentasi' : 'Galeri Tidak Ditemukan',
                subtitle: searchQuery.isEmpty
                    ? 'Belum ada dokumentasi galeri saat ini.'
                    : 'Maaf, kami tidak menemukan dokumentasi yang Anda cari.',
                showResetButton: searchQuery.isNotEmpty,
                onResetTap: onResetFilter,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async { if (onRetry != null) await onRetry!(); },
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
                    return _GalleryCard(item: item);
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

class _GalleryCardSkeleton extends StatelessWidget {
  const _GalleryCardSkeleton();

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
              child: const Text('Judul dokumentasi placeholder', maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final GalleryModel item;

  const _GalleryCard({required this.item});

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => _ImagePreviewDialog(
        imageUrl: item.image,
        title: item.title,
        description: item.description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showImagePreview(context),
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
              Image.network(
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
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: Icon(RemixIcons.image_line, size: 48, color: Colors.grey[600]),
                ),
              ),
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
                left: 12, right: 12, bottom: 12,
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

class _ImagePreviewDialog extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const _ImagePreviewDialog({
    required this.imageUrl,
    required this.title,
    this.description = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(RemixIcons.image_line, color: Colors.white54, size: 64),
                      ),
                    )
                  : Image.asset(imageUrl, fit: BoxFit.contain, width: double.infinity),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(RemixIcons.close_line, color: Colors.white, size: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(RemixIcons.share_line, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Gunakan dua jari untuk memperbesar gambar',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
