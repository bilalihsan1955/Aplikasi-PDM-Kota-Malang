import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../view_models/agenda_view_model.dart';
import '../../../models/agenda_model.dart';
import '../../widgets/back_button_app.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendaViewModel>().loadEvents();
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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(130),
            child: _CombinedHeader(),
          ),
          body: _AgendaListContent(),
        ),
      ),
    );
  }
}

class _CombinedHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(130);

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
    final viewModel = context.watch<AgendaViewModel>();
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
    final viewModel = context.read<AgendaViewModel>();
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
                'Agenda',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Jadwal kegiatan mendatang',
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
    final viewModel = context.read<AgendaViewModel>();
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
              onChanged: viewModel.setSearchQuery,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari agenda...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: () => viewModel.setSearching(false),
            icon: const Icon(RemixIcons.close_line, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  static const List<String> _skeletonFilters = ['Semua', 'Minggu Ini', 'Bulan Ini', 'Akan Datang'];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgendaViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = viewModel.isLoading && viewModel.filteredAgendas.isEmpty;
    final hasError = !viewModel.isLoading && viewModel.errorMessage.isNotEmpty && viewModel.filteredAgendas.isEmpty;

    if (hasError) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: isLoading
          ? Skeletonizer(
              enabled: true,
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _skeletonFilters.length,
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
                      _skeletonFilters[index],
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
              itemCount: viewModel.timeFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = viewModel.timeFilters[index];
                final isActive = filter == viewModel.selectedFilter;

                return GestureDetector(
                  onTap: () => viewModel.setFilter(filter),
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
                      filter,
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

class _AgendaListContent extends StatefulWidget {
  @override
  State<_AgendaListContent> createState() => _AgendaListContentState();
}

class _AgendaListContentState extends State<_AgendaListContent> {
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
    final vm = context.read<AgendaViewModel>();
    if (!vm.hasMore || vm.isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) vm.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgendaViewModel>();
    final filteredAgendas = viewModel.filteredAgendas;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (viewModel.isLoading && filteredAgendas.isEmpty) {
      final dummy = AgendaModel(id: 0, title: 'Judul agenda placeholder', slug: '', description: '', image: '', eventDate: '2025-02-20', eventTime: '09:00:00', location: 'Lokasi placeholder', status: 'upcoming');
      return RefreshIndicator(
        onRefresh: () async => await context.read<AgendaViewModel>().loadEvents(),
        displacement: 40,
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              sliver: SliverSafeArea(
                top: false,
                sliver: Skeletonizer.sliver(
                  enabled: true,
                  child: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _AgendaCard(data: dummy, skeletonStyle: true)),
                      childCount: 5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!viewModel.isLoading && viewModel.errorMessage.isNotEmpty && filteredAgendas.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => await context.read<AgendaViewModel>().loadEvents(),
        displacement: 40,
        color: Theme.of(context).colorScheme.primary,
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
                      Text(viewModel.errorMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.white60 : Colors.grey[600])),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => viewModel.loadEvents(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFF152D8D), borderRadius: BorderRadius.circular(24)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(RemixIcons.refresh_line, size: 18, color: Colors.white), SizedBox(width: 8), Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
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

    if (filteredAgendas.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => await context.read<AgendaViewModel>().loadEvents(),
        displacement: 40,
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: const Alignment(0, -0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(isDark ? 'assets/images/empty_state/not_found_dark.png' : 'assets/images/empty_state/not_found.png', width: 160, height: 160),
                    Text('Agenda Tidak Ditemukan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 8),
                    Text('Maaf, kami tidak menemukan jadwal yang Anda cari.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 13)),
                    const SizedBox(height: 24),
                    if (viewModel.searchQuery.isNotEmpty || viewModel.selectedFilter != 'Semua')
                      GestureDetector(
                        onTap: viewModel.resetFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(color: const Color(0xFF152D8D), borderRadius: BorderRadius.circular(24)),
                          child: const Text('Atur Ulang Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

    return RefreshIndicator(
      onRefresh: () async => await context.read<AgendaViewModel>().loadEvents(),
      displacement: 40,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverSafeArea(
              top: false,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= filteredAgendas.length) {
                      final dummy = AgendaModel(id: 0, title: '...', slug: '', description: '', image: '', eventDate: '2025-02-20', eventTime: '09:00:00', location: '...', status: 'upcoming');
                      return Skeletonizer(enabled: true, child: Padding(padding: const EdgeInsets.only(bottom: 16), child: _AgendaCard(data: dummy, skeletonStyle: true)));
                    }
                    final item = filteredAgendas[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => context.push('/agenda/detail', extra: {'slug': item.slug, 'agenda': item}),
                        child: _AgendaCard(data: item),
                      ),
                    );
                  },
                  childCount: filteredAgendas.length + (viewModel.isLoadingMore ? 1 : 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final AgendaModel data;
  final bool skeletonStyle;

  const _AgendaCard({required this.data, this.skeletonStyle = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateBgColor = skeletonStyle
        ? (isDark ? Colors.white24 : Colors.grey[300])
        : (isDark ? const Color(0xFF152D8D) : const Color(0xFFE0E6F8));
    final dateTextColor = skeletonStyle
        ? (isDark ? Colors.white54 : Colors.grey[600])
        : (isDark ? Colors.white : const Color(0xFF071D75));
    final timeColor = skeletonStyle
        ? (isDark ? Colors.white38 : Colors.grey[500])
        : const Color(0xFF39A658);

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
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: dateBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.month,
                    style: TextStyle(
                      color: dateTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    data.date,
                    style: TextStyle(
                      color: dateTextColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.time.isEmpty ? '–' : data.time,
                    style: TextStyle(
                      color: timeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(RemixIcons.map_pin_line, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey[500], 
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(RemixIcons.arrow_right_s_line, color: Colors.grey[isDark ? 600 : 300], size: 24),
          ],
        ),
      ),
    );
  }
}
