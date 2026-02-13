import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../utils/app_style.dart';
import '../../view_models/notification_view_model.dart';

class NavbarWidgets extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavbarWidgets({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocation = GoRouterState.of(context).uri.toString();
    final isInNotificationPage = currentLocation.contains('/notifications');

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        height: 96,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100, 
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(context, RemixIcons.home_3_fill, RemixIcons.home_3_line, "Home", 0, isInNotificationPage),
            _buildNavItem(context, RemixIcons.calendar_event_fill, RemixIcons.calendar_event_line, "Agenda", 1, isInNotificationPage),
            _buildNavItem(context, RemixIcons.article_fill, RemixIcons.article_line, "Berita", 2, isInNotificationPage),
            _buildNotificationItem(context, isInNotificationPage),
            _buildNavItem(context, RemixIcons.user_3_fill, RemixIcons.user_3_line, "Profil", 3, isInNotificationPage),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, bool isInNotificationPage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = AppStyle.accent;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/notifications');
        },
        behavior: HitTestBehavior.opaque,
        child: Consumer<NotificationViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(isInNotificationPage ? 10 : 8),
                      decoration: BoxDecoration(
                        gradient: isInNotificationPage 
                          ? RadialGradient(
                              center: Alignment.topLeft,
                              radius: 3,
                              colors: [
                                const Color(0xFF39A658).withOpacity(0.15),
                                const Color(0xFF4A6FDB).withOpacity(0.15),
                                const Color(0XFF071D75).withOpacity(0.15),
                              ],
                              stops: const [0.0, 0.3, 0.8],
                            ) 
                          : null,
                        borderRadius: BorderRadius.circular(16),
                        border: isInNotificationPage ? Border.all(
                              color: activeColor.withOpacity(0.1),
                              width: 1.5,
                            ) : null,
                      ),
                      child: Icon(
                        isInNotificationPage ? RemixIcons.notification_3_fill : RemixIcons.notification_3_line,
                        color: isInNotificationPage 
                            ? activeColor 
                            : (isDark ? Colors.white.withOpacity(0.5) : Colors.blueGrey[200]),
                        size: isInNotificationPage ? 30 : 26,
                      ),
                    ),
                    if (viewModel.unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            viewModel.unreadCount > 9 ? '9+' : '${viewModel.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Notifikasi',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isInNotificationPage ? FontWeight.bold : FontWeight.w500,
                    color: isInNotificationPage 
                        ? activeColor 
                        : (isDark ? Colors.white.withOpacity(0.6) : Colors.blueGrey[400]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData iconActive, IconData iconInactive, String label, int index, bool isInNotificationPage) {
    // Jika di halaman notifikasi, jangan tampilkan tab manapun sebagai aktif
    bool isActive = !isInNotificationPage && (currentIndex == index);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Warna aktif menggunakan biru gelap utama
    final Color activeColor = AppStyle.accent;
    final IconData icon = isActive ? iconActive : iconInactive;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact(); 
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isActive ? 10 : 8),
              decoration: BoxDecoration(
                // Menggunakan gradasi biru dengan opacity rendah untuk background item aktif
                gradient: isActive 
                  ? RadialGradient(
                      center: Alignment.topLeft,
                      radius: 3,
                      colors: [
                        const Color(0xFF39A658).withOpacity(0.15),
                        const Color(0xFF4A6FDB).withOpacity(0.15),
                        const Color(0XFF071D75).withOpacity(0.15),
                      ],
                      stops: const [0.0, 0.3, 0.8],
                    ) 
                  : null,
                borderRadius: BorderRadius.circular(16),
                border: isActive ? Border.all (
                      color: activeColor.withOpacity(0.1),
                      width: 1.5,
                    ) : null,
              ),
              child: Icon(
                icon,
                // Ikon aktif berwarna biru gelap
                color: isActive ? activeColor : (isDark ? Colors.white.withOpacity(0.5) : Colors.blueGrey[200]),
                size: isActive ? 30 : 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                // Teks aktif berwarna biru gelap
                color: isActive ? activeColor : (isDark ? Colors.white.withOpacity(0.6) : Colors.blueGrey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
