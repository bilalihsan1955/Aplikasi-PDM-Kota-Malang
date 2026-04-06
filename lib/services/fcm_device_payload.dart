import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Data `device` untuk body POST `/fcm/token` (sesuai kontrak backend).
Future<Map<String, dynamic>> buildFcmDevicePayload() async {
  final plugin = DeviceInfoPlugin();

  if (kIsWeb) {
    final w = await plugin.webBrowserInfo;
    return {
      'id': w.userAgent ?? 'web',
      'name': w.browserName.name,
      'type': 'web',
    };
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      final a = await plugin.androidInfo;
      final name = [a.manufacturer, a.model]
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .join(' ')
          .trim();
      return {
        'id': a.id,
        'name': name.isEmpty ? 'Android' : name,
        'type': 'android',
      };
    case TargetPlatform.iOS:
      final i = await plugin.iosInfo;
      final name = i.name.trim().isNotEmpty ? i.name : i.utsname.machine;
      return {
        'id': i.identifierForVendor ?? '',
        'name': name,
        'type': 'ios',
      };
    case TargetPlatform.macOS:
      final m = await plugin.macOsInfo;
      return {
        'id': m.systemGUID ?? m.model,
        'name': m.model,
        'type': 'macos',
      };
    case TargetPlatform.windows:
      final w = await plugin.windowsInfo;
      return {
        'id': w.deviceId,
        'name': w.computerName,
        'type': 'windows',
      };
    case TargetPlatform.linux:
      final l = await plugin.linuxInfo;
      return {
        'id': l.machineId ?? '',
        'name': l.prettyName,
        'type': 'linux',
      };
    default:
      return {
        'id': 'unknown',
        'name': defaultTargetPlatform.name,
        'type': defaultTargetPlatform.name,
      };
  }
}
