import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';

import 'app_style.dart';

/// Dialog kaca untuk memilih sumber gambar: galeri atau kamera.
/// Mengembalikan [ImageSource] yang dipilih, atau `null` jika dibatalkan.
Future<ImageSource?> showGlassImageSourceDialog({
  required BuildContext context,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final baseBg = isDark ? const Color(0xFF141414) : Colors.white;
  final border = isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06);
  final shadow = isDark ? Colors.black.withOpacity(0.45) : Colors.black.withOpacity(0.10);

  return showGeneralDialog<ImageSource>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Pilih sumber foto',
    barrierColor: Colors.black.withOpacity(isDark ? 0.35 : 0.22),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, __) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  decoration: BoxDecoration(
                    color: baseBg.withOpacity(isDark ? 0.78 : 0.90),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: shadow,
                        blurRadius: 22,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment.topLeft,
                            radius: 2.6,
                            colors: [
                              AppStyle.accent.withOpacity(0.20),
                              AppStyle.accent.withOpacity(0.06),
                            ],
                          ),
                          border: Border.all(color: AppStyle.accent.withOpacity(0.25)),
                        ),
                        child: Icon(RemixIcons.image_add_line, color: AppStyle.accent, size: 26),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Pilih sumber foto',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ambil dari galeri atau foto langsung dengan kamera.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _ImageSourceTile(
                        icon: RemixIcons.image_line,
                        label: 'Galeri',
                        isDark: isDark,
                        border: border,
                        onTap: () => Navigator.of(dialogContext).pop(ImageSource.gallery),
                      ),
                      const SizedBox(height: 10),
                      _ImageSourceTile(
                        icon: RemixIcons.camera_line,
                        label: 'Kamera',
                        isDark: isDark,
                        border: border,
                        onTap: () => Navigator.of(dialogContext).pop(ImageSource.camera),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.of(dialogContext).pop(),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: border),
                              ),
                              child: Text(
                                'Batal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.grey[800],
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color border;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppStyle.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF2D3142),
                  ),
                ),
              ),
              Icon(
                RemixIcons.arrow_right_s_line,
                size: 20,
                color: isDark ? Colors.white38 : Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
