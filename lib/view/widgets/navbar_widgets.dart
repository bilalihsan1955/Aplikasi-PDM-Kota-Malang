import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_filled, "Home", 0),
            _buildNavItem(Icons.receipt_long_rounded, "Agenda", 1),
            _buildNavItem(Icons.bar_chart_rounded, "Berita", 2),
            _buildNavItem(Icons.person_rounded, "Profil", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = currentIndex == index;
    const Color themeColor = Color(0xFF39A658);

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
                // Warna background dibuat sedikit lebih soft
                color: isActive ? themeColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isActive ? Border.all (
                      color: themeColor.withOpacity(0.1), // Border tipis agar lebih sharp
                      width: 1.5,
                    ) : Border.all(color: Colors.transparent),
                // Shadow Container dibuat sangat tipis (subtle)
                boxShadow: isActive ? [
                  BoxShadow(
                    color: themeColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Icon(
                icon,
                color: isActive ? themeColor : Colors.blueGrey[200],
                size: isActive ? 30 : 26,
                // SHADOW ICON DIHAPUS agar tidak terlalu glow
                shadows: const [], 
              ),
            ),
            const SizedBox(height: 4), // Jarak sedikit ditambah agar teks lebih bernapas
            Text(
              label,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? themeColor : Colors.blueGrey[400],
                // Pastikan tidak ada bayangan pada teks juga
              ),
            ),
          ],
        ),
      ),
    );
  }
}