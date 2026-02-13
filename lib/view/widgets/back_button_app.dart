import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';
import '../../utils/app_style.dart';

/// Tombol back dengan animasi gradient (hijau–biru, biru dominan) saat ditekan.
/// Ukuran dan padding tetap 44×44, tanpa mengubah layout.
class BackButtonApp extends StatefulWidget {
  final VoidCallback onTap;

  const BackButtonApp({super.key, required this.onTap});

  @override
  State<BackButtonApp> createState() => _BackButtonAppState();
}

class _BackButtonAppState extends State<BackButtonApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _gradientAnimation;

  static const double _size = 44;
  static const Duration _duration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(curve);
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    // Jangan reverse langsung agar gradient tetap terlihat saat "click"
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onTap() {
    // Saat klik selesai: gradient tetap tampil, jalankan callback, lalu reverse setelah jeda
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final defaultBg = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.shade100;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _gradientAnimation.value;
          final iconColor = Color.lerp(defaultColor, Colors.white, t)!;
          final showShadow = t > 0;

          // Transisi halus: dari solid defaultBg ke gradient (hijau–biru)
          final gradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(defaultBg, AppStyle.accent, t)!,
              Color.lerp(defaultBg, const Color(0xFF2E5AA7), t)!,
              Color.lerp(defaultBg, AppStyle.primary, t)!,
            ],
            stops: const [0.0, 0.35, 1.0],
          );

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: _size,
              width: _size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: showShadow
                    ? [
                        BoxShadow(
                          color: AppStyle.primary.withOpacity(0.35 * t),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
                gradient: gradient,
              ),
              alignment: Alignment.center,
              child: Icon(
                RemixIcons.arrow_left_line,
                size: 24,
                color: iconColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
