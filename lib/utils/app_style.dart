import 'package:flutter/material.dart';

class AppStyle {
  static const Color primary = Color(0xFF152D8D);
  static const Color accent = Color(0xFF39A658);
  static const Color warning = Color(0xFFFFC107); // Warna Kuning
  static const Color scaffoldLight = Color(0xFFFCFCFC);
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  static const EdgeInsets hPadding = EdgeInsets.symmetric(horizontal: 24);

  static const Gradient agendaGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 3,
    colors: [Color(0xFF26C6DA), Color(0xFF4A6FDB), Color(0XFF071D75)],
    stops: [0.0, 0.3, 0.8],
  );
}
