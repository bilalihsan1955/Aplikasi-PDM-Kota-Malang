import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/home_view_model.dart';
import '../../models/event_model.dart';
import '../../models/news_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: const [
              _Header(),
              SizedBox(height: 24),
              _CompanyBanner(),
              SizedBox(height: 24),
              _EventSection(),
              SizedBox(height: 24),
              _HomeMenuSection(),
              SizedBox(height: 8),
              _NewsSection(),
              SizedBox(height: 24),
            ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Bilal Al Ihsan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Text(
                'Bagaimana kabarmu hari ini',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF152D8D),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/profile.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyBanner extends StatelessWidget {
  const _CompanyBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/banner.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tentang PDM Malang',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.6,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Mengenal lebih dekat visi, misi, dan perjalanan organisasi kami.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventSection extends StatelessWidget {
  const _EventSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final events = viewModel.events;
        final visibleEvents = events.length > 2 ? 2 : events.length;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _SectionHeader(
                title: 'Agenda Terkini',
                onTapAll: () => context.go('/agenda'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: PageView.builder(
                padEnds: false,
                controller: PageController(viewportFraction: 0.88),
                itemCount: visibleEvents,
                onPageChanged: viewModel.setEventPage,
                itemBuilder: (context, index) {
                  return _EventCard(
                    event: events[index],
                    margin: EdgeInsets.only(
                      left: index == 0 ? 24 : 8,
                      right: index == visibleEvents - 1 ? 24 : 8,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _DotsIndicator(
              length: visibleEvents,
              current: viewModel.currentEventPage,
            ),
          ],
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final EdgeInsets margin;

  const _EventCard({required this.event, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 3,
          colors: [Color(0xFF26C6DA), Color(0xFF4A6FDB), Color(0XFF071D75)],
          stops: [0.0, 0.3, 0.8],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _EventDate(event: event),
          const SizedBox(width: 16),
          _EventInfo(event: event),
        ],
      ),
    );
  }
}

class _EventDate extends StatelessWidget {
  final EventModel event;

  const _EventDate({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF152D8D).withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.month,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    event.date,
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                event.month,
                style: const TextStyle(
                  color: Color(0xFF2D3142),
                  fontWeight: FontWeight.w900 ,
                  fontSize: 12,
                ),
              ),
              Text(
                event.date,
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _EventInfo extends StatelessWidget {
  final EventModel event;

  const _EventInfo({required this.event});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(event.time, style: const TextStyle(color: Colors.white)),
              Container(
                height: 12,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white54,
              ),
              Expanded(
                child: Text(
                  event.location,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
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
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(title: 'Menu Utama'),
        ),
        SizedBox(height: 16),
        _HomeMenuGrid(),
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
        itemCount: viewModel.homeMenus.length,
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
              if (item['label'] == 'Berita') context.go('/berita');
              if (item['label'] == 'Agenda') context.go('/agenda');
              if (item['label'] == 'Profil') context.go('/profile');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    item['icon'],
                    color: themeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['label'],
                  textAlign: TextAlign.center,
                  maxLines: 1,
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

class _NewsSection extends StatelessWidget {
  const _NewsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          final newsData = viewModel.news;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Berita Terkini',
                onTapAll: () => context.go('/berita'),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: newsData.length > 4 ? 4 : newsData.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return _NewsCard(data: newsData[index]);
                },
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

  const _NewsCard({required this.data});

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
                  Image.asset(data.image, fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.1)),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0XFF071D75) : const Color(0xFFD6DCEF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        data.tag,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFD6DCEF) : const Color(0XFF071D75),
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
                      color: isDark ? Colors.white : const Color(0xFF2D3142),
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
