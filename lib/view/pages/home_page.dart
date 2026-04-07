import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../view_models/home_view_model.dart';
import '../../models/agenda_model.dart';
import '../../models/auth_user_model.dart';
import '../../models/news_model.dart';
import '../../services/auth/auth_local_service.dart';
import '../../services/prayer_time_service.dart';
import '../../utils/in_app_webview_nav.dart';
import '../widgets/user_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _canRefresh = false;

  @override
  void initState() {
    super.initState();
    unawaited(AuthLocalService().getCachedUser());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _canRefresh = true);
      });
    });
  }

  Future<void> _onRefresh() async {
    await context.read<HomeViewModel>().refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF152D8D),
        notificationPredicate: (_) => _canRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const _Header(),
                const SizedBox(height: 24),
                const _SearchSection(),
                const SizedBox(height: 24),
                Consumer<HomeViewModel>(
                  builder: (_, vm, __) => _NewsSlide(
                    currentIndex: vm.slideIndex,
                    news: vm.featuredNews,
                    loading: vm.featuredLoading,
                  ),
                ),
                const SizedBox(height: 16),
                const _PrayerQiblaSection(),
                const SizedBox(height: 24),
                const _EventSection(),
                const _HomeMenuSection(),
                const SizedBox(height: 8),
                const _NewsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthUser?>(
      valueListenable: AuthLocalService.cachedUserNotifier,
      builder: (context, user, _) {
        final name = user?.name.trim();
        final displayName = (name == null || name.isEmpty) ? 'Pengguna' : name;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $displayName',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Text(
                      'Bagaimana kabarmu hari ini',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF152D8D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: UserAvatar(
                    user: user,
                    size: 50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => context.push('/menu', extra: {'openSearch': true}),
        child: Hero(
          tag: 'menu_search',
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFE8ECF4),
                  width: 1,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    RemixIcons.search_line,
                    size: 22,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Cari menu, layanan, informasi...',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white38 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsSlide extends StatelessWidget {
  const _NewsSlide({
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
              child: _NewsSlideCard(key: ValueKey<int>(item.id), news: item),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsSlideCard extends StatelessWidget {
  const _NewsSlideCard({super.key, required this.news});
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

class _EventSection extends StatefulWidget {
  const _EventSection();

  @override
  State<_EventSection> createState() => _EventSectionState();
}

class _EventSectionState extends State<_EventSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HomeViewModel>();
      vm.loadUpcomingEvents();
      vm.loadFeaturedNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final events = viewModel.events;
        final loading = viewModel.eventsLoading;
        // Maksimal 2 agenda yang akan datang; jika kosong section tidak ditampilkan
        const maxDisplay = 2;
        final visibleCount = events.length > maxDisplay
            ? maxDisplay
            : events.length;

        if (!loading && events.isEmpty) {
          return const SizedBox.shrink();
        }

        if (loading && events.isEmpty) {
          final dummy = AgendaModel(
            id: 0,
            title: 'Agenda placeholder',
            slug: '',
            description: '',
            image: '',
            eventDate: '2025-02-20',
            eventTime: '09:00:00',
            location: 'Lokasi',
            status: 'upcoming',
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  title: 'Agenda Terkini',
                  onTapAll: () => context.go('/agenda'),
                ),
              ),
              const SizedBox(height: 8),
              Skeletonizer(
                enabled: true,
                child: SizedBox(
                  height: 136,
                  child: PageView.builder(
                    padEnds: false,
                    clipBehavior: Clip.none,
                    controller: PageController(viewportFraction: 0.88),
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EventCard(
                          event: dummy,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 24 : 8,
                            right: index == 1 ? 24 : 8,
                          ),
                          skeletonStyle: true,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const _DotsIndicator(length: 2, current: 0),
              const SizedBox(height: 24),
            ],
          );
        }

        final isSingleCard = visibleCount == 1;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _SectionHeader(
                title: 'Agenda Terkini',
                onTapAll: () => context.go('/agenda'),
              ),
            ),
            const SizedBox(height: 8),
            if (isSingleCard)
              SizedBox(
                height: 136,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 16,
                  ),
                  child: GestureDetector(
                    onTap: () => context.push(
                      '/agenda/detail',
                      extra: {'slug': events[0].slug, 'agenda': events[0]},
                    ),
                    child: _EventCard(
                      event: events[0],
                      margin: EdgeInsets.zero,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 136,
                child: PageView.builder(
                  padEnds: false,
                  clipBehavior: Clip.none,
                  controller: PageController(viewportFraction: 0.88),
                  itemCount: visibleCount,
                  onPageChanged: viewModel.setEventPage,
                  itemBuilder: (context, index) {
                    final item = events[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => context.push(
                          '/agenda/detail',
                          extra: {'slug': item.slug, 'agenda': item},
                        ),
                        child: _EventCard(
                          event: item,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 24 : 8,
                            right: index == visibleCount - 1 ? 24 : 8,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (!isSingleCard) ...[
              const SizedBox(height: 8),
              _DotsIndicator(
                length: visibleCount,
                current: viewModel.currentEventPage,
              ),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final AgendaModel event;
  final EdgeInsets margin;
  final bool skeletonStyle;

  const _EventCard({
    required this.event,
    required this.margin,
    this.skeletonStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: skeletonStyle
            ? null
            : const RadialGradient(
                center: Alignment.topLeft,
                radius: 3,
                colors: [
                  Color(0xFF39A658),
                  Color(0xFF4A6FDB),
                  Color(0XFF071D75),
                ],
                stops: [0.0, 0.3, 0.8],
              ),
        color: skeletonStyle
            ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
            : null,
        borderRadius: BorderRadius.circular(24),
        border: skeletonStyle
            ? Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF1F4F9),
                width: 1.5,
              )
            : null,
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
          children: [
            if (!skeletonStyle)
              Positioned(
                right: -20,
                top: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/pattern.png',
                    fit: BoxFit.cover,
                    height: 160,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  _EventDate(event: event, skeletonStyle: skeletonStyle),
                  const SizedBox(width: 16),
                  _EventInfo(event: event, skeletonStyle: skeletonStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDate extends StatelessWidget {
  final AgendaModel event;
  final bool skeletonStyle;

  const _EventDate({required this.event, this.skeletonStyle = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = skeletonStyle
        ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0))
        : (isDark
              ? const Color(0xFF152D8D).withOpacity(0.8)
              : const Color(0xFFFCFCFC));
    final textColor = skeletonStyle
        ? (isDark ? Colors.white70 : const Color(0xFF2D3142))
        : (isDark ? Colors.white : const Color(0xFF2D3142));
    final child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          event.month,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          event.date,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
    if (isDark && !skeletonStyle) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: child,
            ),
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class _EventInfo extends StatelessWidget {
  final AgendaModel event;
  final bool skeletonStyle;

  const _EventInfo({required this.event, this.skeletonStyle = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = skeletonStyle
        ? (isDark ? Colors.white70 : const Color(0xFF2D3142))
        : Colors.white;
    final subColor = skeletonStyle
        ? (isDark ? Colors.white54 : Colors.grey[500])
        : Colors.white70;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(RemixIcons.time_line, color: subColor, size: 16),
              const SizedBox(width: 4),
              Text(
                event.time.isEmpty ? '–' : event.time,
                style: TextStyle(color: textColor),
              ),
              Container(
                height: 12,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: subColor,
              ),
              Expanded(
                child: Text(
                  event.location,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeMenuSection extends StatelessWidget {
  const _HomeMenuSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(
            title: 'Menu Utama',
            onTapAll: () => context.push('/menu'),
          ),
        ),
        const SizedBox(height: 8),
        const _HomeMenuGrid(),
      ],
    );
  }
}

class _HomeMenuGrid extends StatelessWidget {
  const _HomeMenuGrid();

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF39A658);
    final viewModel = context.watch<HomeViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: viewModel.homeMenus.length > 8
            ? 8
            : viewModel.homeMenus.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 0,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final item = viewModel.homeMenus[index];

          return GestureDetector(
            onTap: () {
              if (item['label'] == 'sholat')
                context.push(
                  '/jadwal-sholat',
                  extra: {'prayer': viewModel.prayerTime},
                );
              if (item['label'] == 'Berita') context.go('/berita');
              if (item['label'] == 'Agenda') context.go('/agenda');
              if (item['label'] == 'Profil') context.go('/about-pdm');
              if (item['label'] == 'Dokumentasi') context.push('/gallery');
              if (item['label'] == 'Amal Usaha') context.push('/amal-usaha');
              if (item['label'] == 'Notifikasi') context.push('/notifications');
              if (item['label'] == 'KHGT') {
                pushInAppWebView(
                  context,
                  url: 'https://khgt.muhammadiyah.or.id/kalendar-hijriah',
                  title: 'KHGT',
                );
              }
              if (item['label'] == 'Cari') context.push('/menu');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFC300).withOpacity(0.25),
                        themeColor.withOpacity(0.25),
                      ],
                      begin: index.isEven
                          ? Alignment.topLeft
                          : Alignment.bottomRight,
                      end: index.isEven
                          ? Alignment.bottomRight
                          : Alignment.topLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(item['icon'], color: themeColor, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  item['label'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF2D3142),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PrayerQiblaSection extends StatefulWidget {
  const _PrayerQiblaSection();

  @override
  State<_PrayerQiblaSection> createState() => _PrayerQiblaSectionState();
}

class _PrayerQiblaSectionState extends State<_PrayerQiblaSection> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<HomeViewModel>();
    if (vm.prayerTime == null && vm.prayerLoading) {
      vm.loadPrayerData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<HomeViewModel>(
      builder: (_, vm, __) {
        final loading = vm.prayerLoading;
        final prayer = vm.prayerTime;
        final isSkeleton = loading && prayer == null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Skeletonizer(
            enabled: isSkeleton,
            effect: ShimmerEffect(
              baseColor: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFE0E0E0),
              highlightColor: isDark
                  ? const Color(0xFF3A3A3A)
                  : const Color(0xFFF5F5F5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSkeleton
                    ? null
                    : () => context.push(
                          '/jadwal-sholat',
                          extra: {'prayer': prayer},
                        ),
                borderRadius: BorderRadius.circular(20),
                child: _HomeNextPrayerBlueBanner(
                  prayer: prayer,
                  isDark: isDark,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _prayerIconAsset(String prayerName) {
  final file = prayerName.toLowerCase().replaceAll(' ', '_');
  return 'assets/images/jadwal_sholat/$file.png';
}

class _HomeNextPrayerBlueBanner extends StatefulWidget {
  const _HomeNextPrayerBlueBanner({
    required this.prayer,
    required this.isDark,
  });

  final PrayerTimeResult? prayer;
  final bool isDark;

  static String _cityTitle(String raw) {
    if (raw.isEmpty) return raw;
    return raw
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  @override
  State<_HomeNextPrayerBlueBanner> createState() =>
      _HomeNextPrayerBlueBannerState();
}

class _HomeNextPrayerBlueBannerState extends State<_HomeNextPrayerBlueBanner> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayer = widget.prayer;
    final isDark = widget.isDark;
    final next = prayer?.nextPrayer;
    final name = next?.name ?? 'Subuh';
    final time = next?.time ?? '00.00';
    final city = _HomeNextPrayerBlueBanner._cityTitle(prayer?.city ?? 'Lokasi');
    final countdown = prayer != null
        ? PrayerTimeResult.formatCountdownId(prayer.durationUntilNextPrayer)
        : '-- mnt';

    final isSkeleton = prayer == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: isSkeleton
            ? null
            : const LinearGradient(
                colors: [Color(0xFF152D8D), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isSkeleton
            ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSkeleton
              ? (isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE0E0E0))
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sholat berikutnya',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.82),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                        color: Colors.white.withOpacity(0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: Image.asset(
                  _prayerIconAsset(name),
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.9),
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (_, __, ___) => Icon(
                    RemixIcons.time_line,
                    size: 38,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                RemixIcons.map_pin_2_fill,
                size: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  city.isEmpty ? 'Lokasi' : city,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  countdown,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewsSection extends StatefulWidget {
  const _NewsSection();

  @override
  State<_NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<_NewsSection> {
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
              _SectionHeader(
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
                                child: _NewsCard(
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
                                child: _NewsCard(
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
                                child: _NewsCard(data: newsData[i]),
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
                                      child: _NewsCard(data: newsData[i + 1]),
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
                        data.tag.isEmpty ? 'Kategori' : data.tag[0].toUpperCase() + data.tag.substring(1).toLowerCase(),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTapAll;

  const _SectionHeader({required this.title, this.onTapAll});

  @override
  Widget build(BuildContext context) {
    const Color appBlue = Color(0xFF152D8D);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
        ),
        TextButton(
          onPressed: onTapAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: appBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Semua',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : appBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int length;
  final int current;

  const _DotsIndicator({required this.length, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: current == i ? 20 : 8,
          decoration: BoxDecoration(
            color: current == i
                ? const Color(0xFF152D8D)
                : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
