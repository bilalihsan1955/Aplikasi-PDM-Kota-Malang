import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../view_models/profile_view_model.dart';
import '../../../view_models/auth_view_model.dart';
import '../../../utils/app_style.dart';
import '../../../utils/in_app_webview_nav.dart';
import '../../../utils/glass_confirm_dialog.dart';
import '../../../utils/top_snackbar.dart';
import '../../../services/api_service.dart';
import '../../../services/auth/auth_local_service.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/back_button_app.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Consumer<AuthViewModel>(
          builder: (context, authVm, _) {
            final isSubmitting = authVm.isSubmitting;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final overlayColor = isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.12);

            return Stack(
              fit: StackFit.expand,
              children: [
                AbsorbPointer(
                  absorbing: isSubmitting,
                  child: SingleChildScrollView(
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _header(context),
                          const SizedBox(height: 24),
                          _profileCard(context),
                          const SizedBox(height: 24),
                          _section('Informasi'),
                          _infoSection(context),
                          const SizedBox(height: 24),
                          _section('Pengaturan'),
                          _settingsSection(context),
                          const SizedBox(height: 24),
                          _logout(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isSubmitting)
                  Positioned.fill(
                    child: IgnorePointer(child: Container(color: overlayColor)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ===== SECTIONS =====
  Widget _infoSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey[200]!;
    final infoMenus = [
      (RemixIcons.community_line, 'Profil Organisasi', '/about-pdm'),
      (RemixIcons.article_line, 'Berita & Pengumuman', '/berita'),
      (RemixIcons.calendar_event_line, 'Agenda Kegiatan', '/agenda'),
      (RemixIcons.image_line, 'Dokumentasi', '/gallery'),
    ];

    return Container(
      margin: AppStyle.hPadding,
      decoration: _cardShellDecoration(context),
      child: Material(
        color: _cardSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(infoMenus.length, (index) {
            final item = infoMenus[index];
            return Column(
              children: [
                _menuItem(
                  context: context,
                  icon: item.$1,
                  title: item.$2,
                  onTap: () {
                    if (item.$3 == '/berita' || item.$3 == '/agenda') {
                      context.go(item.$3);
                    } else {
                      context.push(item.$3);
                    }
                  },
                ),
                if (index != infoMenus.length - 1)
                  Divider(height: 1, thickness: 1, color: dividerColor),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _settingsSection(BuildContext context) {
    final isPlatformDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey[200]!;

    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        bool currentSwitchValue = viewModel.themeMode == ThemeMode.system
            ? isPlatformDark
            : viewModel.isDarkMode;

        return Container(
          margin: AppStyle.hPadding,
          decoration: _cardShellDecoration(context),
          child: Material(
            color: _cardSurfaceColor(context),
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _menuItem(
                  context: context,
                  icon: RemixIcons.user_line,
                  title: 'Akun Saya',
                  onTap: () => context.push('/profile/account'),
                ),
                Divider(height: 1, thickness: 1, color: dividerColor),
                _menuItem(
                  context: context,
                  icon: currentSwitchValue
                      ? RemixIcons.sun_line
                      : RemixIcons.moon_line,
                  title: currentSwitchValue ? 'Tema Terang' : 'Tema Gelap',
                  trailing: Switch(
                    value: currentSwitchValue,
                    activeColor: AppStyle.accent,
                    activeTrackColor: AppStyle.accent.withOpacity(0.1),
                    inactiveThumbColor: isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey[400],
                    inactiveTrackColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[200],
                    trackOutlineColor: MaterialStateProperty.all(
                      Colors.transparent,
                    ),
                    onChanged: viewModel.toggleDarkMode,
                  ),
                ),
                Divider(height: 1, thickness: 1, color: dividerColor),
                _menuItem(
                  context: context,
                  icon: RemixIcons.alarm_line,
                  title: 'Alarm & pengingat Sholat',
                  trailing: Switch(
                    value: viewModel.prayerAlarmReminderEnabled,
                    activeColor: AppStyle.accent,
                    activeTrackColor: AppStyle.accent.withOpacity(0.1),
                    inactiveThumbColor: isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey[400],
                    inactiveTrackColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[200],
                    trackOutlineColor: MaterialStateProperty.all(
                      Colors.transparent,
                    ),
                    onChanged: viewModel.setPrayerAlarmReminderEnabled,
                  ),
                ),
                Divider(height: 1, thickness: 1, color: dividerColor),
                _menuItem(
                  context: context,
                  icon: RemixIcons.question_line,
                  title: 'Bantuan',
                  onTap: () => pushInAppWebView(
                    context,
                    url: '${ApiService.webBaseUrl}/kontak/webview',
                    title: 'Bantuan',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== COMPONENTS =====
  Widget _header(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: AppStyle.hPadding,
      child: Row(
        children: [
          BackButtonApp(onTap: () => context.go('/')),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informasi akun anda',
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

  Widget _profileCard(BuildContext context) {
    final cardRadius = BorderRadius.circular(20);
    final splash = AppStyle.primary.withOpacity(0.14);
    final highlight = AppStyle.primary.withOpacity(0.07);

    return Padding(
      padding: AppStyle.hPadding,
      child: Container(
        decoration: _cardShellDecoration(context),
        child: Material(
          color: _cardSurfaceColor(context),
          borderRadius: cardRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/profile/account'),
            borderRadius: cardRadius,
            splashColor: splash,
            highlightColor: highlight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppStyle.accent.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: FutureBuilder(
                      future: AuthLocalService().getCachedUser(),
                      builder: (context, snapshot) {
                        return UserAvatar(
                          user: snapshot.data,
                          size: 64,
                          borderRadius: BorderRadius.circular(32),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                          future: AuthLocalService().getCachedUser(),
                          builder: (context, snapshot) {
                            final name = snapshot.data?.name.trim();
                            final displayName = (name == null || name.isEmpty)
                                ? 'Pengguna'
                                : name;
                            return Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder(
                          future: AuthLocalService().getCachedUser(),
                          builder: (context, snapshot) {
                            final pos = snapshot.data?.position?.trim();
                            final displayPos = (pos == null || pos.isEmpty)
                                ? 'Anggota Organisasi'
                                : pos;
                            return Text(
                              displayPos,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final splash = AppStyle.primary.withOpacity(0.14);
    final highlight = AppStyle.primary.withOpacity(0.07);

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 3,
                colors: [
                  const Color(0xFF26C6DA).withOpacity(0.15),
                  const Color(0xFF4A6FDB).withOpacity(0.15),
                  const Color(0XFF071D75).withOpacity(0.15),
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppStyle.primary.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: AppStyle.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withOpacity(0.9)
                        : const Color(0xFF2D3142),
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing ??
              Icon(
                RemixIcons.arrow_right_s_line,
                color: Colors.grey[400],
                size: 24,
              ),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return InkWell(
      onTap: onTap,
      splashColor: splash,
      highlightColor: highlight,
      child: row,
    );
  }

  Widget _logout(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    final splash = Colors.redAccent.withOpacity(0.12);
    final highlight = Colors.redAccent.withOpacity(0.06);

    return Padding(
      padding: AppStyle.hPadding,
      child: Container(
        decoration: _cardShellDecoration(context),
        child: Material(
          color: _cardSurfaceColor(context),
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showLogoutDialog(context),
            borderRadius: borderRadius,
            splashColor: splash,
            highlightColor: highlight,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(RemixIcons.logout_box_r_line, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
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

  Future<void> _showLogoutDialog(BuildContext context) async {
    final ok = await showGlassConfirmDialog(
      context: context,
      title: 'Keluar dari akun?',
      message: 'Anda akan logout dan data lokal akan dihapus dari perangkat.',
      confirmText: 'Logout',
      cancelText: 'Batal',
      icon: RemixIcons.logout_box_r_line,
      iconColor: Colors.redAccent,
      confirmGradient: const RadialGradient(
        center: Alignment.topLeft,
        radius: 4,
        colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
        stops: [0.0, 1.0],
      ),
    );

    if (ok != true) return;

    final result = await context.read<AuthViewModel>().logout();
    if (!context.mounted) return;

    showTopSnackBar(context, result.message, isError: !result.success);

    if (result.success) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!context.mounted) return;
      context.go('/login');
    }
  }

  /// Hanya border + bayangan; warna isi di [Material] agar ripple [InkWell] tampil di atas kartu.
  BoxDecoration _cardShellDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF1F4F9),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Color _cardSurfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }
}
