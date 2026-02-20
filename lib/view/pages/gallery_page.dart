import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../widgets/back_button_app.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _isSearching = false;
  String _searchQuery = '';

  void _setSearching(bool value) => setState(() => _isSearching = value);
  void _setSearchQuery(String value) => setState(() => _searchQuery = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: _CombinedHeader(
            isSearching: _isSearching,
            onSearchChanged: _setSearchQuery,
            onToggleSearch: _setSearching,
          ),
        ),
        body: _GalleryList(
          searchQuery: _searchQuery,
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
    super.key,
    required this.isSearching,
    required this.onSearchChanged,
    required this.onToggleSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

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
    super.key,
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
  const _HeaderTitle({super.key, required this.onToggleSearch});

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

  const _SearchBar({super.key, required this.onSearchChanged, required this.onToggleSearch});

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
  final String searchQuery;
  const _GalleryList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final List<Map<String, String>> galleryData = [
      {'image': 'assets/images/banner.png', 'title': 'Rapat Pleno Pimpinan PDM'},
      {'image': 'assets/images/banner.png', 'title': 'Kunjungan Kerja ke Sekolah'},
      {'image': 'assets/images/banner.png', 'title': 'Bakti Sosial Ramadhan'},
      {'image': 'assets/images/banner.png', 'title': 'Seminar Dakwah Digital'},
      {'image': 'assets/images/banner.png', 'title': 'Peresmian Masjid Baru'},
      {'image': 'assets/images/banner.png', 'title': 'Pelatihan Kader Organisasi'},
      {'image': 'assets/images/banner.png', 'title': 'Kajian Rutin Ahad Pagi'},
      {'image': 'assets/images/banner.png', 'title': 'Pemberdayaan Ekonomi Umat'},
    ];

    final filteredItems = galleryData
        .where((item) => item['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ditemukan',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return CustomScrollView(
      physics: const ClampingScrollPhysics(), // Menghilangkan efek bounce
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
                  return _GalleryCard(
                    image: filteredItems[index]['image']!,
                    title: filteredItems[index]['title']!,
                  );
                },
                childCount: filteredItems.length,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final String image;
  final String title;

  const _GalleryCard({required this.image, required this.title});

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => _ImagePreviewDialog(image: image, title: title),
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
              Image.asset(image, fit: BoxFit.cover),
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
                  title,
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
  final String image;
  final String title;

  const _ImagePreviewDialog({required this.image, required this.title});

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
            child: Center(child: Image.asset(image, fit: BoxFit.contain, width: double.infinity)),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20, right: 20,
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
            left: 24, right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Gunakan dua jari untuk memperbesar gambar', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
