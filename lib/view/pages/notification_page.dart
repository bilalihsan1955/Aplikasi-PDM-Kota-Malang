import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../view_models/notification_view_model.dart';
import '../../models/notification_model.dart';
import '../../utils/app_style.dart';
import '../../utils/notification_navigation.dart';
import '../widgets/back_button_app.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications();
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
            preferredSize: const Size.fromHeight(160),
            child: _CombinedHeader(),
          ),
          body: _NotificationListContent(),
        ),
      ),
    );
  }
}

class _CombinedHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(160);

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
            _HeaderTitle(),
            const SizedBox(height: 16),
            _CategoryChips(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          BackButtonApp(onTap: () => context.go('/')),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notifikasi',
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
                  'Informasi terbaru untuk anda',
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
    );
  }
}

class _CategoryChips extends StatelessWidget {
  static const List<String> _skeletonChips = ['Semua', 'Berita', 'Agenda', 'Web'];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = viewModel.loading && viewModel.notifications.isEmpty;
    final hasError =
        !viewModel.loading && viewModel.error != null && viewModel.notifications.isEmpty;

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
                itemCount: _skeletonChips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
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
              itemCount: viewModel.filterTipeKeys.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final tipeKey = viewModel.filterTipeKeys[index];
                final label = viewModel.filterChipLabel(tipeKey);
                final isActive = tipeKey == viewModel.selectedTipeFilter;

                return GestureDetector(
                  onTap: () => viewModel.setFilter(tipeKey),
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
                      label,
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

class _NotificationListContent extends StatelessWidget {
  static NotificationModel get _skeletonDummy => NotificationModel(
        id: 0,
        title: 'Judul notifikasi placeholder',
        body:
            'Isi notifikasi placeholder untuk tampilan loading skeleton pada daftar.',
        topic: 'all',
        urlRedirect: 'x',
        tipeRedirect: 'news',
        createdAt: DateTime.now(),
        isRead: false,
      );

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    final notifications = viewModel.filteredNotifications;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (viewModel.loading && notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        color: const Color(0xFF152D8D),
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
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NotificationCard(
                          notification: _skeletonDummy,
                          onTap: () {},
                          onDelete: () {},
                          skeletonStyle: true,
                        ),
                      ),
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

    if (viewModel.error != null && notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                RemixIcons.wifi_off_line,
                size: 48,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => viewModel.refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: const Alignment(0, -0.2),
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
                    'Belum Ada Notifikasi',
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
                      'Notifikasi akan muncul di sini',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      color: const Color(0xFF152D8D),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            sliver: SliverSafeArea(
              top: false,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _NotificationCard(
                      notification: notifications[index],
                      onTap: () {
                        viewModel.markAsRead(notifications[index].id);
                        openNotificationTarget(context, notifications[index]);
                      },
                      onDelete: () {
                        viewModel.deleteNotification(notifications[index].id);
                      },
                    );
                  },
                  childCount: notifications.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool skeletonStyle;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    this.skeletonStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.read<NotificationViewModel>();
    final tipeLabel = viewModel.tipeDisplayLabel(notification.tipeRedirect);
    final metaLine = [
      if (tipeLabel.isNotEmpty) tipeLabel,
      viewModel.formatCreatedAt(notification.createdAt),
      viewModel.getTimeAgo(notification.createdAt),
    ].join(' · ');

    final iconBg = skeletonStyle
        ? (isDark ? Colors.white24 : Colors.grey[300])
        : viewModel.getColorForTipe(notification.tipeRedirect).withOpacity(0.1);
    final iconFg = skeletonStyle
        ? (isDark ? Colors.white54 : Colors.grey[600])
        : viewModel.getColorForTipe(notification.tipeRedirect);

    final card = GestureDetector(
      onTap: skeletonStyle ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: skeletonStyle
                ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!)
                : notification.isRead
                    ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!)
                    : AppStyle.accent.withOpacity(0.3),
            width: skeletonStyle || notification.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                skeletonStyle
                    ? RemixIcons.notification_3_line
                    : viewModel.getIconForTipe(notification.tipeRedirect),
                color: iconFg,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!skeletonStyle && !notification.isRead)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppStyle.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          metaLine,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.grey[500],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!skeletonStyle &&
                          notification.urlRedirect != null &&
                          notification.urlRedirect!.isNotEmpty)
                        Icon(
                          RemixIcons.arrow_right_s_line,
                          size: 16,
                          color: isDark ? Colors.white38 : Colors.grey[400],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (skeletonStyle) return card;

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(RemixIcons.delete_bin_line, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: card,
    );
  }
}
