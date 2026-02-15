  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:go_router/go_router.dart';
  import 'package:remixicon/remixicon.dart';
  import 'package:skeletonizer/skeletonizer.dart';
  import '../../../view_models/news_view_model.dart';
  import '../../../models/news_model.dart';
  import '../../../view/widgets/back_button_app.dart';

  class BeritaPage extends StatefulWidget {
    const BeritaPage({super.key});

    @override
    State<BeritaPage> createState() => _BeritaPageState();
  }

  class _BeritaPageState extends State<BeritaPage> {
    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NewsViewModel>().loadNews();
      });
    }

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
                Positioned.fill(child: _NewsGrid()),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _CombinedHeader(),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  class _CombinedHeader extends StatelessWidget {
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
              _AnimatedHeader(),
              const SizedBox(height: 16),
              _CategoryChips(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
  }

  class _AnimatedHeader extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      final viewModel = context.watch<NewsViewModel>();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: viewModel.isSearching ? _SearchBar() : _HeaderTitle(),
        ),
      );
    }
  }

  class _HeaderTitle extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      final viewModel = context.read<NewsViewModel>();
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
                  'Berita',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informasi terbaru untuk anda',
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
            onPressed: () => viewModel.setSearching(true),
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
    @override
    Widget build(BuildContext context) {
      final viewModel = context.read<NewsViewModel>();
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
                onChanged: viewModel.setSearchQuery,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintText: 'Cari judul berita...',
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
                onTap: () => viewModel.setSearching(false),
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
    static const List<String> _skeletonChips = ['Semua', 'Kategori', 'Berita', 'Info', 'Update'];

    @override
    Widget build(BuildContext context) {
      final viewModel = context.watch<NewsViewModel>();
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final isLoading = viewModel.isLoading && viewModel.filteredNews.isEmpty;

      return SizedBox(
        height: 40,
        child: isLoading
            ? Skeletonizer(
                enabled: true,
                child: ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _skeletonChips.length,
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
                        _skeletonChips[index],
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
                itemCount: viewModel.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final tag = viewModel.categories[index];
                  final isActive = tag == viewModel.selectedTag;

                  return GestureDetector(
                    onTap: () => viewModel.setTag(tag),
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
                        tag,
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

  class _NewsGrid extends StatefulWidget {
    @override
    State<_NewsGrid> createState() => _NewsGridState();
  }

  class _NewsGridState extends State<_NewsGrid> {
    final ScrollController _scrollController = ScrollController();

    @override
    void initState() {
      super.initState();
      _scrollController.addListener(_onScroll);
    }

    @override
    void dispose() {
      _scrollController.removeListener(_onScroll);
      _scrollController.dispose();
      super.dispose();
    }

    void _onScroll() {
      final vm = context.read<NewsViewModel>();
      if (!vm.hasMore || vm.isLoadingMore) return;
      final pos = _scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent - 200) {
        vm.loadMore();
      }
    }

    @override
    Widget build(BuildContext context) {
      final viewModel = context.watch<NewsViewModel>();
      final filteredNews = viewModel.filteredNews;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      double topPadding = MediaQuery.of(context).padding.top + 160;
      double bottomPadding = MediaQuery.of(context).padding.bottom + 24;
      double skeletonTopPadding = MediaQuery.of(context).padding.top + 112;

      if (viewModel.isLoading && filteredNews.isEmpty) {
        final dummyNews = [
          NewsModel.fromCard(
            tag: 'Kategori',
            time: '0 menit lalu',
            title: 'Judul berita placeholder pertama untuk skeleton',
            desc: 'Deskripsi singkat berita placeholder.',
            image: 'assets/images/bg.webp',
          ),
          NewsModel.fromCard(
            tag: 'Info',
            time: '1 jam lalu',
            title: 'Judul berita placeholder kedua',
            desc: 'Deskripsi singkat untuk kartu skeleton.',
            image: 'assets/images/profile.png',
          ),
        ];
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<NewsViewModel>().loadNews();
          },
          displacement: 200,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          color: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: EdgeInsets.only(top: skeletonTopPadding, left: 24, right: 24, bottom: bottomPadding),
            child: Skeletonizer(
              enabled: true,
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => _NewsCard(data: dummyNews[index % 2], skeletonStyle: true),
              ),
            ),
          ),
        );
      }

      if (!viewModel.isLoading && viewModel.errorMessage.isNotEmpty && filteredNews.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<NewsViewModel>().loadNews();
          },
          displacement: 200,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          color: Theme.of(context).colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            padding: EdgeInsets.only(top: topPadding),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - topPadding - 100,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RemixIcons.error_warning_line, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => viewModel.loadNews(),
                        icon: const Icon(RemixIcons.refresh_line, size: 20),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      if (filteredNews.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<NewsViewModel>().loadNews();
          },
          displacement: 200,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          color: Theme.of(context).colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            padding: EdgeInsets.only(top: topPadding),
            child: Align(
              alignment: const Alignment(0, -0.4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    isDark 
                        ? 'assets/images/empty_state/not_found_dark.png' 
                        : 'assets/images/empty_state/not_found.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    'Berita Tidak Ditemukan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      'Maaf, kami tidak menemukan berita yang Anda cari.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (viewModel.searchQuery.isNotEmpty || viewModel.selectedTag != 'Semua')
                    GestureDetector(
                      onTap: viewModel.resetFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF152D8D),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Atur Ulang Filter',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await context.read<NewsViewModel>().loadNews();
        },
        displacement: 200,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        color: Theme.of(context).colorScheme.primary,
        child: GridView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: EdgeInsets.only(
            top: topPadding,
            left: 24,
            right: 24,
            bottom: bottomPadding,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredNews.length + (viewModel.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredNews.length) {
            final dummy = NewsModel.fromCard(
              tag: '...',
              time: '...',
              title: 'Memuat...',
              desc: '...',
              image: 'assets/images/bg.webp',
            );
            return Skeletonizer(
              enabled: true,
              child: _NewsCard(data: dummy, skeletonStyle: true),
            );
          }
          final item = filteredNews[index];
          return GestureDetector(
            onTap: () => context.push('/berita/detail', extra: {'slug': item.slug, 'news': item}),
            child: _NewsCard(data: item),
          );
        },
        ),
      );
    }
  }

  class _NewsCard extends StatelessWidget {
    final NewsModel data;
    final bool skeletonStyle;
    const _NewsCard({required this.data, this.skeletonStyle = false});

    Widget _buildNewsImage(String image, bool isDark) {
      if (image.startsWith('http://') || image.startsWith('https://')) {
        return Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: isDark ? Colors.white10 : Colors.grey[200]),
        );
      }
      return Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(color: isDark ? Colors.white10 : Colors.grey[200]),
      );
    }

    @override
    Widget build(BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildNewsImage(data.image, isDark),
                    Container(
                      color: Colors.black.withOpacity(0.1),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: skeletonStyle
                              ? (isDark ? Colors.white24 : Colors.grey[300])
                              : (isDark ? const Color(0xFF11683B) : const Color(0xFFD1EBDD)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          data.tag.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: skeletonStyle
                                ? (isDark ? Colors.white54 : Colors.grey[600])
                                : (isDark ? const Color(0xFFD1EBDD) : const Color(0xFF11683B)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.time,
                      style: TextStyle(
                        fontSize: 11, 
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        data.desc,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
