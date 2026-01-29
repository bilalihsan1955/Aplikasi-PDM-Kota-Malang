import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // ===== MENU DATA =====
  static const _infoMenus = [
    (Icons.apartment, 'Profil Organisasi'),
    (Icons.article_outlined, 'Berita & Pengumuman'),
    (Icons.event_outlined, 'Agenda Kegiatan'),
    (Icons.photo_library_outlined, 'Dokumentasi'),
  ];

  static const _settingMenus = [
    (Icons.person_outline, 'Akun Saya'),
    (Icons.notifications_none, 'Notifikasi'),
    (Icons.help_outline, 'Bantuan'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 24),
            _profileCard(),
            const SizedBox(height: 24),
        
            _section('Informasi'),
            _menuGroup(_infoMenus),
        
            const SizedBox(height: 24),
        
            _section('Pengaturan'),
            _menuGroup(_settingMenus),
        
            const SizedBox(height: 24),
            _logout(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Padding(
      padding: AppStyle.hPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Informasi akun anda',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          _circleIcon(Icons.settings),
        ],
      ),
    );
  }

  // ===== PROFILE CARD =====
  // ===== PROFILE CARD (Updated) =====
  Widget _profileCard() {
    return Container(
      margin: AppStyle.hPadding,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          // Avatar dengan ring border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppStyle.accent.withOpacity(0.2), width: 2),
            ),
            child: _avatar(),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bilal Al Ihsan',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
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

  // ===== SECTION TITLE =====
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

  // ===== MENU GROUP =====
  Widget _menuGroup(List<(IconData, String)> items) {
    return Container(
      margin: AppStyle.hPadding,
      decoration: _cardDecoration(),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              _menuItem(item.$1, item.$2),
              if (index != items.length - 1)
                Divider(height: 1, color: Colors.grey[200]),
            ],
          );
        }),
      ),
    );
  }

  // ===== MENU ITEM =====
  // ===== MENU ITEM (Updated) =====
  Widget _menuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Container Ikon yang disinkronkan dengan Navbar/Menu Grid
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppStyle.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16), // Radius yang konsisten
              border: Border.all(
                color: AppStyle.accent.withOpacity(0.1), // Border tipis biar sharp
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: AppStyle.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142), // Warna teks yang lebih elegan
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 24),
        ],
      ),
    );
  }

  // ===== LOGOUT =====
  Widget _logout() {
    return Container(
      margin: AppStyle.hPadding,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: _cardDecoration(),
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

  // ===== REUSABLE =====
  Widget _circleIcon(IconData icon) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: AppStyle.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _avatar() {
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// ===== STYLE CONSTANT =====
class AppStyle {
  static const primary = Color(0xFF152D8D);
  static const accent = Color(0xFF39A658);

  static const hPadding = EdgeInsets.symmetric(horizontal: 24);
}
