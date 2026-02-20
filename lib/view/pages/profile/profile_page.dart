import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../view_models/profile_view_model.dart';
import '../../../utils/app_style.dart';
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
        body: SingleChildScrollView(
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
    );
  }

  // ===== SECTIONS =====
  Widget _infoSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!;
    final infoMenus = [
      (RemixIcons.community_line, 'Profil Organisasi', '/about-pdm'),
      (RemixIcons.article_line, 'Berita & Pengumuman', '/berita'),
      (RemixIcons.calendar_event_line, 'Agenda Kegiatan', '/agenda'),
      (RemixIcons.image_line, 'Dokumentasi', '/gallery'),
    ];

    return Container(
      margin: AppStyle.hPadding,
      decoration: _cardDecoration(context),
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
    );
  }

  Widget _settingsSection(BuildContext context) {
    final isPlatformDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!;

    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        bool currentSwitchValue = viewModel.themeMode == ThemeMode.system 
            ? isPlatformDark 
            : viewModel.isDarkMode;

        return Container(
          margin: AppStyle.hPadding,
          decoration: _cardDecoration(context),
          child: Column(
            children: [
              _menuItem(
                context: context, 
                icon: RemixIcons.user_line, 
                title: 'Akun Saya',
                onTap: () => context.push('/profile/account'), // Perbaikan: Menambahkan Navigasi
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),
              _menuItem(
                context: context,
                icon: currentSwitchValue ? RemixIcons.sun_line : RemixIcons.moon_line,
                title: currentSwitchValue ? 'Tema Terang' : 'Tema Gelap',
                trailing: Switch(
                  value: currentSwitchValue,
                  activeColor: AppStyle.accent,
                  activeTrackColor: AppStyle.accent.withOpacity(0.1),
                  inactiveThumbColor: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[400],
                  inactiveTrackColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                  trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                  onChanged: viewModel.toggleDarkMode,
                ),
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),
              _menuItem(
                context: context,
                icon: RemixIcons.notification_3_line,
                title: 'Notifikasi',
                trailing: Switch(
                  value: viewModel.notificationsEnabled,
                  activeColor: AppStyle.accent,
                  activeTrackColor: AppStyle.accent.withOpacity(0.1),
                  inactiveThumbColor: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[400],
                  inactiveTrackColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                  trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                  onChanged: viewModel.toggleNotifications,
                ),
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),
              _menuItem(context: context, icon: RemixIcons.question_line, title: 'Bantuan'),
            ],
          ),
        );
      },
    );
  }

  // ===== COMPONENTS =====
  Widget _header(BuildContext context) {
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
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                Text(
                  'Informasi akun anda',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    return Container(
      margin: AppStyle.hPadding,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppStyle.accent.withOpacity(0.2), width: 2),
            ),
            child: _avatar(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bilal Al Ihsan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Anggota Organisasi',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
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
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF2D3142),
                ),
              ),
            ),
            trailing ?? Icon(RemixIcons.arrow_right_s_line, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _logout(BuildContext context) {
    return Container(
      margin: AppStyle.hPadding,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: _cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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
    );
  }

  Widget _avatar(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: AppStyle.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.asset(
          'assets/images/profile.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
