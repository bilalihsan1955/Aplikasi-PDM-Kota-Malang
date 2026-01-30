import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/profile_view_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
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
    );
  }

  // ===== SECTIONS =====
  Widget _infoSection(BuildContext context) {
    final infoMenus = [
      (Icons.apartment, 'Profil Organisasi'),
      (Icons.article_outlined, 'Berita & Pengumuman'),
      (Icons.event_outlined, 'Agenda Kegiatan'),
      (Icons.photo_library_outlined, 'Dokumentasi'),
    ];

    return Container(
      margin: AppStyle.hPadding,
      decoration: _cardDecoration(context),
      child: Column(
        children: List.generate(infoMenus.length, (index) {
          final item = infoMenus[index];
          return Column(
            children: [
              _menuItem(context: context, icon: item.$1, title: item.$2),
              if (index != infoMenus.length - 1)
                Divider(height: 1, color: Theme.of(context).dividerTheme.color),
            ],
          );
        }),
      ),
    );
  }

  Widget _settingsSection(BuildContext context) {
    final isPlatformDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        // Jika mode system, switch mengikuti brightness device
        bool currentSwitchValue = viewModel.themeMode == ThemeMode.system 
            ? isPlatformDark 
            : viewModel.isDarkMode;

        return Container(
          margin: AppStyle.hPadding,
          decoration: _cardDecoration(context),
          child: Column(
            children: [
              _menuItem(context: context, icon: Icons.person_outline, title: 'Akun Saya'),
              Divider(height: 1, color: Theme.of(context).dividerTheme.color),
              _menuItem(
                context: context,
                icon: currentSwitchValue ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
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
              Divider(height: 1, color: Theme.of(context).dividerTheme.color),
              _menuItem(
                context: context,
                icon: Icons.notifications_none,
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
              Divider(height: 1, color: Theme.of(context).dividerTheme.color),
              _menuItem(context: context, icon: Icons.help_outline, title: 'Bantuan'),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
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
          trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 24),
        ],
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
          Icon(Icons.logout, color: Colors.redAccent),
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

class AppStyle {
  static const primary = Color(0xFF152D8D);
  static const accent = Color(0xFF39A658);
  static const hPadding = EdgeInsets.symmetric(horizontal: 24);
}
