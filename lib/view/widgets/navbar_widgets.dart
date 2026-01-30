import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_style.dart';

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
            _buildNavItem(context, Icons.home_filled, "Home", 0),
            _buildNavItem(context, Icons.receipt_long_rounded, "Agenda", 1),
            _buildNavItem(context, Icons.bar_chart_rounded, "Berita", 2),
            _buildNavItem(context, Icons.person_rounded, "Profil", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    bool isActive = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Warna aktif menggunakan biru gelap utama
    final Color activeColor = AppStyle.accent;

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
