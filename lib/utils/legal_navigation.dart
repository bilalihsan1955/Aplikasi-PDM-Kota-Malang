import 'package:flutter/material.dart';
import '../services/api/api_service.dart';
import 'in_app_webview_nav.dart';

/// Utilitas navigasi untuk dokumen legal (Privacy Policy & Terms & Conditions).
/// Mengarah ke URL khusus WebView di backend Makotamu (tanpa navbar/footer web).
class LegalNavigation {
  /// URL WebView khusus untuk Kebijakan Privasi (Privacy Policy)
  static String get privacyPolicyUrl {
    final base = ApiService.webBaseUrl.replaceAll(RegExp(r'/+$'), '');
    return '$base/privacy-policy/webview';
  }

  /// URL WebView khusus untuk Syarat & Ketentuan (Terms & Conditions)
  static String get termsUrl {
    final base = ApiService.webBaseUrl.replaceAll(RegExp(r'/+$'), '');
    return '$base/terms/webview';
  }

  /// Membuka halaman Kebijakan Privasi di dalam aplikasi (In-App WebView)
  static Future<void> openPrivacyPolicy(BuildContext context) {
    return pushInAppWebView(
      context,
      url: privacyPolicyUrl,
      title: 'Kebijakan Privasi',
    );
  }

  /// Membuka halaman Syarat & Ketentuan di dalam aplikasi (In-App WebView)
  static Future<void> openTerms(BuildContext context) {
    return pushInAppWebView(
      context,
      url: termsUrl,
      title: 'Syarat & Ketentuan',
    );
  }
}
