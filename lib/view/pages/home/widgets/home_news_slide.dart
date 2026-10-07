import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pdm_malang/models/news_model.dart';

class HomeNewsSlide extends StatelessWidget {
  const HomeNewsSlide({
    super.key,
    required this.currentIndex,
    required this.news,
    required this.loading,
  });

  final int currentIndex;
  final List<NewsModel> news;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading && news.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Skeletonizer(
          enabled: true,
          child: Container(
            height: 200,
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
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                  Image.asset('assets/images/bg.webp', fit: BoxFit.cover),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Judul berita placeholder',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Deskripsi singkat berita yang memberikan gambaran konten.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (news.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () => context.go('/berita'),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.grey[200],
            ),
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
          ),
        ),
      );
    }
    final index = currentIndex % news.length;
    final item = news[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => context.push(
          '/berita/detail',
          extra: {'slug': item.slug, 'news': item},
        ),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (Widget child, Animation<double> animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.25, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: FadeTransition(
                    opacity: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(curved),
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.94,
                        end: 1.0,
                      ).animate(curved),
                      child: child,
                    ),
                  ),
                );
              },
              child: HomeNewsSlideCard(key: ValueKey<int>(item.id), news: item),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeNewsSlideCard extends StatelessWidget {
  const HomeNewsSlideCard({super.key, required this.news});
  final NewsModel news;

  @override
  Widget build(BuildContext context) {
    final imageWidget =
        (news.image.startsWith('http://') || news.image.startsWith('https://'))
        ? Image.network(
            news.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : (news.image.isNotEmpty
              ? Image.asset(
                  news.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder());
    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                news.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.6,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                news.desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(RemixIcons.image_line, size: 48),
    );
  }
}
