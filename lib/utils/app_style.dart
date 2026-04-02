import 'package:flutter/material.dart';

class AppStyle {
  static const Color primary = Color(0xFF152D8D);
  static const Color accent = Color(0xFF39A658);
  static const Color warning = Color(0xFFFFC107); // Warna Kuning
  static const Color scaffoldLight = Color(0xFFFCFCFC);
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  /// Ikon prefix field di tema gelap (primary terlalu gelap di atas [cardDark]).
  static Color formPrefixIconColor(bool isDark) =>
      isDark ? const Color(0xFFB0C4FF) : primary;

  /// Label field: [Colors.grey[600]] sulit dibaca di scaffold gelap.
  static Color formLabelColor(bool isDark) =>
      isDark ? const Color(0xFFD6D6D6) : const Color(0xFF616161);

  /// Aksen hijau tombol/teks di atas kartu gelap.
  static Color accentOnSurface(bool isDark) =>
      isDark ? const Color(0xFF6EE89A) : accent;

  static const EdgeInsets hPadding = EdgeInsets.symmetric(horizontal: 24);

  static const Gradient agendaGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 3,
    colors: [Color(0xFF26C6DA), Color(0xFF4A6FDB), Color(0XFF071D75)],
    stops: [0.0, 0.3, 0.8],
  );
}
