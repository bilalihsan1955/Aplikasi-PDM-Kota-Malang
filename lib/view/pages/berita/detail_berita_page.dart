import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../utils/app_style.dart';
import '../../../models/news_model.dart';
import '../../../services/news_api_service.dart';
import '../../widgets/back_button_app.dart';

class DetailBeritaPage extends StatefulWidget {
  final String? slug;
  final NewsModel? initialNews;

  const DetailBeritaPage({super.key, this.slug, this.initialNews});

  @override
  State<DetailBeritaPage> createState() => _DetailBeritaPageState();
}

class _DetailBeritaPageState extends State<DetailBeritaPage> {
  final ScrollController _scrollController = ScrollController();
  final NewsApiService _api = NewsApiService();
  bool _isScrolled = false;
  bool _loading = true;
  String? _error;
  NewsModel? _news;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50) {
        if (!_isScrolled) setState(() => _isScrolled = true);
      } else {
        if (_isScrolled) setState(() => _isScrolled = false);
      }
    });
    if (widget.initialNews != null) {
      _news = widget.initialNews;
      _loading = false;
    }
    if (widget.slug != null && widget.slug!.isNotEmpty) {
      _loadDetail();
    } else if (widget.initialNews == null) {
      _loading = false;
    }
  }

  Future<void> _loadDetail() async {
    final slug = widget.slug;
    if (slug == null || slug.isEmpty) return;
    if (_news == null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final item = await _api.getBySlug(slug);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (item != null) {
        _news = item;
        _error = null;
      } else if (_news == null) {
        _error = 'Gagal memuat berita';
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppStyle.scaffoldDark : Colors.white;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final title = _news?.title ?? 'Berita Terkini';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildBody(isDark, cardColor),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isScrolled ? appBarColor : Colors.transparent,
                boxShadow: _isScrolled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: SafeArea(
                bottom: false,
                child: _isScrolled
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                BackButtonApp(onTap: () => context.pop()),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF2D3142),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Detail berita',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.white70 : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          children: [
                            _circleNavButton(
                              icon: RemixIcons.arrow_left_line,
                              onTap: () => context.pop(),
                              showWhiteBg: true,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark, Color cardColor) {
    if (widget.slug == null || widget.slug!.isEmpty) {
      return _buildStaticContent(isDark, cardColor);
    }
    if (_loading) {
      return _buildDetailSkeleton(isDark, cardColor);
    }
    if (_error != null || _news == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                RemixIcons.error_warning_line,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Berita tidak ditemukan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadDetail,
                icon: const Icon(RemixIcons.refresh_line, size: 20),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return _buildDetailContent(_news!, isDark, cardColor);
  }

  Widget _buildStaticContent(bool isDark, Color cardColor) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: 400,
            width: double.infinity,
            child: Image.asset('assets/images/banner.png', fit: BoxFit.cover),
          ),
          Container(
            transform: Matrix4.translationValues(0, -40, 0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryTag('CORPORATE'),
                    const SizedBox(height: 20),
                    const Text(
                      'Q3 Financial Results: Strategic Growth in Asian Markets',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAuthorInfo(isDark, 'Sarah Jenkins', '24 Oct 2023 • 4 min read'),
                    const SizedBox(height: 24),
                    Divider(color: isDark ? Colors.white10 : Colors.grey[200]),
                    const SizedBox(height: 24),
                    Text(
                      'The company today announced robust third-quarter results, driven largely by accelerated adoption of our enterprise solutions across the Asia-Pacific region.\n\nStrategic investments in digital infrastructure and a focused approach to market expansion have yielded significant returns.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF4A4A4A),
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

  Widget _buildDetailContent(NewsModel news, bool isDark, Color cardColor) {
    final imageWidget = (news.image.startsWith('http://') || news.image.startsWith('https://'))
        ? Image.network(
            news.image,
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 400,
              color: isDark ? Colors.white10 : Colors.grey[200],
              child: const Icon(Icons.broken_image_outlined, size: 48),
            ),
          )
        : Image.asset(
            news.image,
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 400,
              color: isDark ? Colors.white10 : Colors.grey[200],
            ),
          );

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 400, width: double.infinity, child: imageWidget),
          Container(
            transform: Matrix4.translationValues(0, -40, 0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryTag(news.tag.trim().isEmpty ? 'BERITA' : news.tag.toUpperCase()),
                    const SizedBox(height: 20),
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAuthorInfo(
                      isDark,
                      news.author?.name ?? 'Admin',
                      news.publishedAtFormatted.isNotEmpty
                          ? news.publishedAtFormatted
                          : (news.time.isNotEmpty ? news.time : (news.publishedAt ?? '')),
                    ),
                    if (news.views > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${news.views} dilihat',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Divider(color: isDark ? Colors.white10 : Colors.grey[200]),
                    const SizedBox(height: 24),
                    Text(
                      news.displayContent,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF4A4A4A),
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

  Widget _circleNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool showWhiteBg,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: showWhiteBg ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: showWhiteBg
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: showWhiteBg ? Colors.black87 : (isDark ? Colors.white : Colors.black87),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDetailSkeleton(bool isDark, Color cardColor) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 400,
              width: double.infinity,
              child: ColoredBox(
                color: isDark ? Colors.white10 : (Colors.grey[200] ?? Colors.grey),
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0, -40, 0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryTag('KATEGORI'),
                      const SizedBox(height: 20),
                      const Text(
                        'Judul berita placeholder yang cukup panjang untuk dua baris',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama Penulis',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : const Color(0xFF1A1F36),
                                ),
                              ),
                              const Text(
                                '4 Feb 2025 • 10:00',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: isDark ? Colors.white10 : Colors.grey[200]),
                      const SizedBox(height: 24),
                      const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        style: TextStyle(fontSize: 16, height: 1.8),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppStyle.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppStyle.accent,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(bool isDark, String name, String subtitle) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isDark ? Colors.white24 : Colors.grey[300],
          child: Text(
            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF1A1F36),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
