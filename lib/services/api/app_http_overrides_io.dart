import 'dart:io';

import 'app_http.dart';

class _AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..userAgent = AppHttp.userAgent;
  }
}

/// Ganti User-Agent default `Dart/x.y (dart:io)` pada setiap `HttpClient` baru.
/// Wajib dipanggil di awal `main()` dan di isolat background FCM.
void installAppHttpOverrides() {
  HttpOverrides.global = _AppHttpOverrides();
}
