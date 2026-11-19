import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pdm_malang/services/api/app_http_overrides.dart';

/// Wajib untuk isolat background FCM di Android; daftar sebelum [runApp].
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  installAppHttpOverrides();
  await Firebase.initializeApp();
}
