import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pdm_malang/models/news_model.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';
import 'home_section_header.dart';

class HomeNewsSection extends StatefulWidget {
  const HomeNewsSection({super.key});

  @override
  State<HomeNewsSection> createState() => _HomeNewsSectionState();
}

class _HomeNewsSectionState extends State<HomeNewsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadLatestNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          final newsData = viewModel.news;
          final loading = viewModel.newsLoading;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeSectionHeader(
                title: 'Berita Terkini',
                onTapAll: () => context.go('/berita'),
              ),
              const SizedBox(height: 8),
              if (loading && newsData.isEmpty)
                Column(
                  children: [
                    for (var i = 0; i < 2; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: i < 1 ? 16 : 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Skeletonizer(
                                enabled: true,
                                child: HomeNewsCard(
                                  data: NewsModel.fromCard(
                                    tag: 'Muhammadiyah',
                                    time:
                                        'Diposting pada: 12 Januari 2024, 15:30 WIB',
                                    title:
                                        'Judul berita skeleton yang sangat panjang untuk memastikan tampilan bones yang maksimal',
                                    desc:
                                        'Deskripsi berita skeleton yang mencakup dua baris penuh untuk memberikan gambaran area skeleton yang lebih luas dan informatif bagi pengguna.',
                                    image: 'assets/images/bg.webp',
                                  ),
                                  skeletonStyle: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Skeletonizer(
                                enabled: true,
                                child: HomeNewsCard(
                                  data: NewsModel.fromCard(
                                    tag: 'Info PDM',
                                    time:
                                        'Diposting pada: 13 Januari 2024, 09:15 WIB',
                                    title:
                                        'Contoh judul berita placeholder lainnya yang juga panjang dan mendetail',
                                    desc:
                                        'Deskripsi placeholder tambahan untuk memastikan konsistensi visual pada blok skeletonizer di seluruh halaman aplikasi.',
                                    image: 'assets/images/bg.webp',
                                  ),
                                  skeletonStyle: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              else if (newsData.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Berita belum tersedia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (
                      var i = 0;
                      i < (newsData.length > 4 ? 4 : newsData.length);
                      i += 2
                    )
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i + 2 <
                                  (newsData.length > 4 ? 4 : newsData.length)
                              ? 16
                              : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push(
                                  '/berita/detail',
                                  extra: {
                                    'slug': newsData[i].slug,
                                    'news': newsData[i],
                                  },
                                ),
                                child: HomeNewsCard(data: newsData[i]),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: (i + 1 < newsData.length)
                                  ? GestureDetector(
                                      onTap: () => context.push(
                                        '/berita/detail',
                                        extra: {
                                          'slug': newsData[i + 1].slug,
                                          'news': newsData[i + 1],
                                        },
                                      ),
                                      child: HomeNewsCard(data: newsData[i + 1]),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class HomeNewsCard extends StatelessWidget {
  final NewsModel data;
  final bool skeletonStyle;

  const HomeNewsCard({
    super.key,
    required this.data,
    this.skeletonStyle = false,
  });

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
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFFF1F4F9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: _buildNewsImage(data.image, isDark),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Skeleton.leaf(
                    enabled: skeletonStyle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: skeletonStyle
                            ? (isDark ? Colors.white38 : Colors.grey[400])
                            : (isDark
                                  ? const Color(0XFF071D75)
                                  : const Color(0xFFD6DCEF)),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        data.tag.isEmpty
                            ? 'Kategori'
                            : data.tag[0].toUpperCase() +
                                data.tag.substring(1).toLowerCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: skeletonStyle
                              ? (isDark ? Colors.white54 : Colors.grey[600])
                              : (isDark
                                    ? const Color(0xFFD6DCEF)
                                    : const Color(0XFF071D75)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Skeleton.leaf(
                  enabled: skeletonStyle,
                  child: SizedBox(
                    width: skeletonStyle ? 120 : null,
                    child: Text(
                      data.time.isEmpty ? 'Memuat waktu...' : data.time,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Skeleton.leaf(
                  enabled: skeletonStyle,
                  child: SizedBox(
                    width: skeletonStyle ? double.infinity : null,
                    child: Text(
                      data.title.isEmpty
                          ? 'Judul berita skeleton yang panjang'
                          : data.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D3142),
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Skeleton.leaf(
                  enabled: skeletonStyle,
                  child: SizedBox(
                    width: skeletonStyle ? double.infinity : null,
                    child: Text(
                      data.desc.isEmpty
                          ? 'Deskripsi berita placeholder yang mencakup dua baris untuk skeletonizer.'
                          : data.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
