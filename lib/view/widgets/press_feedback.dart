import 'package:flutter/material.dart';

/// Feedback tekan tanpa ripple/overlay luar.
/// Efeknya hanya perubahan warna di dalam area tombol.
class PressFeedback extends StatefulWidget {
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Color pressedOverlayColor;
  final Widget child;

  const PressFeedback({
    super.key,
    required this.onTap,
    required this.borderRadius,
    required this.pressedOverlayColor,
    required this.child,
  });

  @override
  State<PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<PressFeedback> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOut,
                opacity: _pressed ? 1 : 0,
                child: ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: ColoredBox(color: widget.pressedOverlayColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

