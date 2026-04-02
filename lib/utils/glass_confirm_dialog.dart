import 'dart:ui';

import 'package:flutter/material.dart';

Future<bool?> showGlassConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
  required IconData icon,
  required Color iconColor,
  Gradient? confirmGradient,
  bool barrierDismissible = true,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final baseBg = isDark ? const Color(0xFF141414) : Colors.white;
  final border = isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06);
  final shadow = isDark ? Colors.black.withOpacity(0.45) : Colors.black.withOpacity(0.10);

  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: title,
    barrierColor: Colors.black.withOpacity(isDark ? 0.35 : 0.22),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) {
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Supaya aman di layar pendek: konten bisa scroll.
                      final maxH = MediaQuery.of(context).size.height * 0.8;
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxH),
                        child: SingleChildScrollView(
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
                                      iconColor.withOpacity(0.20),
                                      iconColor.withOpacity(0.06),
                                    ],
                                  ),
                                  border: Border.all(color: iconColor.withOpacity(0.25)),
                                ),
                                child: Icon(icon, color: iconColor, size: 26),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF2D3142),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: isDark ? Colors.white70 : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _GlassDialogButton(
                                      label: cancelText,
                                      onTap: () => Navigator.of(context).pop(false),
                                      borderColor: border,
                                      textColor: isDark ? Colors.white70 : Colors.grey[800]!,
                                      background: Colors.transparent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _GlassDialogButton(
                                      label: confirmText,
                                      onTap: () => Navigator.of(context).pop(true),
                                      borderColor: Colors.transparent,
                                      textColor: Colors.white,
                                      background: null,
                                      gradient: confirmGradient,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

class _GlassDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color borderColor;
  final Color textColor;
  final Color? background;
  final Gradient? gradient;

  const _GlassDialogButton({
    required this.label,
    required this.onTap,
    required this.borderColor,
    required this.textColor,
    required this.background,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            color: background,
            gradient: gradient,
            boxShadow: gradient == null
                ? null
                : [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

