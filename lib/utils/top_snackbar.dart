import 'package:flutter/material.dart';

OverlayEntry? _activeOverlayEntry;

/// Menampilkan SnackBar dengan gaya "floating" dari atas.
/// Didesain supaya bisa dipakai ulang di halaman mana pun.
void showTopSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlayState = Overlay.of(context);

  // Hapus snackbar sebelumnya agar tidak bertumpuk.
  _activeOverlayEntry?.remove();

  final effectiveDuration = (duration == const Duration(seconds: 3) &&
          (message.contains('\n') || message.length > 100))
      ? const Duration(seconds: 6)
      : duration;

  final topPadding = MediaQuery.of(context).padding.top;
  final top = topPadding + 18;
  final bg = isError ? Colors.redAccent : Colors.green;

  final entry = OverlayEntry(
    builder: (ctx) {
      return Positioned(
        top: top,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(begin: Offset(0, -0.15), end: Offset.zero),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            builder: (context, offset, child) {
              return Transform.translate(offset: offset * 24, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bg.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      message,
                      softWrap: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      isError ? Icons.error_outline : Icons.check_circle,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  _activeOverlayEntry = entry;
  overlayState.insert(entry);

  Future.delayed(effectiveDuration).then((_) {
    entry.remove();
    if (_activeOverlayEntry == entry) _activeOverlayEntry = null;
  });
}

