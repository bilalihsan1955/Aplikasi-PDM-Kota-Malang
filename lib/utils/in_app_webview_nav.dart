import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigator root yang dipakai [GoRouter].
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Lokasi rute `webview` di cabang shell sesuai path saat ini (untuk bottom bar).
String webviewShellLocationForPath(String path) {
  if (path.startsWith('/agenda')) return '/agenda/webview';
  if (path.startsWith('/berita')) return '/berita/webview';
  if (path.startsWith('/profile')) return '/profile/webview';
  return '/webview';
}

/// Membuka WebView di **cabang shell** yang sedang aktif agar bottom bar tetap tampil.
Future<void> pushInAppWebView(
  BuildContext context, {
  required String url,
  String? title,
}) {
  final shellPath = GoRouterState.of(context).uri.path;
  final location = webviewShellLocationForPath(shellPath);
  return context.push<Object?>(
    location,
    extra: {'url': url, 'title': title},
  );
}
