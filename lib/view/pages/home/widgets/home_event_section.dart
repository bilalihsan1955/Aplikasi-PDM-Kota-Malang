import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pdm_malang/models/agenda_model.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';
import 'home_section_header.dart';

class HomeEventSection extends StatefulWidget {
  const HomeEventSection({super.key});

  @override
  State<HomeEventSection> createState() => _HomeEventSectionState();
}

class _HomeEventSectionState extends State<HomeEventSection> {
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
                child: HomeSectionHeader(
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
                        child: HomeEventCard(
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
              const HomeDotsIndicator(length: 2, current: 0),
              const SizedBox(height: 24),
            ],
          );
        }

        final isSingleCard = visibleCount == 1;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: HomeSectionHeader(
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
                    child: HomeEventCard(
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
                        child: HomeEventCard(
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
              HomeDotsIndicator(
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

class HomeEventCard extends StatelessWidget {
  final AgendaModel event;
  final EdgeInsets margin;
  final bool skeletonStyle;

  const HomeEventCard({
    super.key,
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
                  HomeEventDate(event: event, skeletonStyle: skeletonStyle),
                  const SizedBox(width: 16),
                  HomeEventInfo(event: event, skeletonStyle: skeletonStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeEventDate extends StatelessWidget {
  final AgendaModel event;
  final bool skeletonStyle;

  const HomeEventDate({
    super.key,
    required this.event,
    this.skeletonStyle = false,
  });

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

class HomeEventInfo extends StatelessWidget {
  final AgendaModel event;
  final bool skeletonStyle;

  const HomeEventInfo({
    super.key,
    required this.event,
    this.skeletonStyle = false,
  });

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
