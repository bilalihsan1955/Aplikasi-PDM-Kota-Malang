import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const MethodChannel _kExternalBrowserChannel =
    MethodChannel('pdm_malang/external_browser');

/// Buka [url] di **browser luar** (bukan WebView in-app).
/// Android: [Intent.createChooser] agar App Links tidak memaksa kembali ke app ini.
/// iOS: [UIApplication.open] dengan universalLinksOnly: false ke Safari/browser.
Future<bool> openInExternalBrowser(String url) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return false;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme) return false;

  if (kIsWeb) {
    return launchUrl(uri, webOnlyWindowName: '_blank');
  }

  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      final ok = await _kExternalBrowserChannel.invokeMethod<bool>(
        'openUrl',
        trimmed,
      );
      if (ok == true) return true;
    } on PlatformException {
      // fallback di bawah
    }
  }

  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return true;
    }
    return await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (_) {
    return false;
  }
}
