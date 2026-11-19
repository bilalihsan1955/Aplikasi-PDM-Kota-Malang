import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Identitas aplikasi dan klien HTTP bersama untuk seluruh request ke backend Makotamu.
///
/// Tanpa header eksplisit, paket `http` mengirim `User-Agent: Dart/x.y (dart:io)` yang
/// dikenali WAF (mis. Imunify360) sebagai alat otomasi. Semua service backend wajib
/// memakai [AppHttp.client] agar identitas, timeout, dan penanganan error seragam.
class AppHttp {
  AppHttp._();

  /// Application ID Android (sama dengan `applicationId` di Gradle).
  static const String appId = 'id.makotamu.app';

  /// User-Agent jujur yang mengidentifikasi aplikasi (bukan menyamar sebagai browser).
  static const String userAgent =
      'Makotamu/1.0 (Android; $appId; +https://makotamu.org)';

  /// Batas tunggu header respons sebelum request dianggap gagal.
  static const Duration timeout = Duration(seconds: 20);

  /// Klien bersama untuk seluruh service backend.
  static final http.Client client = AppHttpClient(http.Client());

  /// Pesan yang ditampilkan ketika server membalas error dengan konten non-JSON
  /// (halaman blokir firewall, halaman error HTML hosting, dll.).
  static String nonJsonErrorMessage(int statusCode) =>
      'Server sedang tidak dapat memproses permintaan (kode $statusCode). '
      'Silakan coba lagi beberapa saat lagi.';
}

/// [http.BaseClient] yang menambahkan identitas aplikasi, timeout, dan mengubah
/// respons error non-JSON menjadi JSON `{success: false, message: ...}` agar
/// service yang membaca `message` tidak menampilkan teks mentah dari server.
class AppHttpClient extends http.BaseClient {
  AppHttpClient(this._inner, {this.timeout = AppHttp.timeout});

  final http.Client _inner;
  final Duration timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Browser melarang mengubah User-Agent, dan header kustom memicu preflight CORS.
    if (!kIsWeb) {
      request.headers.putIfAbsent('User-Agent', () => AppHttp.userAgent);
      request.headers.putIfAbsent('X-Requested-With', () => AppHttp.appId);
    }

    final response = await _inner.send(request).timeout(timeout);
    return _normalizeNonJsonError(request, response);
  }

  Future<http.StreamedResponse> _normalizeNonJsonError(
    http.BaseRequest request,
    http.StreamedResponse response,
  ) async {
    final acceptsJson =
        (request.headers['Accept'] ?? '').toLowerCase().contains('json');
    final contentType = (response.headers['content-type'] ?? '').toLowerCase();

    if (!acceptsJson ||
        response.statusCode < 400 ||
        contentType.contains('json')) {
      return response;
    }

    final rawBody = await response.stream.bytesToString();
    if (kDebugMode) {
      final preview = rawBody.substring(0, math.min(rawBody.length, 300));
      debugPrint(
        '[AppHttp] ${request.method} ${request.url} -> HTTP ${response.statusCode} '
        'non-JSON ($contentType): $preview',
      );
    }

    final bytes = utf8.encode(jsonEncode({
      'success': false,
      'message': AppHttp.nonJsonErrorMessage(response.statusCode),
    }));

    return http.StreamedResponse(
      Stream.value(bytes),
      response.statusCode,
      contentLength: bytes.length,
      request: request,
      headers: {
        ...response.headers,
        'content-type': 'application/json; charset=utf-8',
      },
      reasonPhrase: response.reasonPhrase,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
    );
  }

  @override
  void close() => _inner.close();
}
