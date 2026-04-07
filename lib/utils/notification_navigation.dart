import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/notification_model.dart';
import '../services/auth/auth_local_service.dart';
import 'app_go_router.dart';
import 'in_app_webview_nav.dart';
import 'pending_auth_redirect.dart';

/// Target rute awal saat app dibuka dari notifikasi (cold start), tanpa lewat home.
class NotificationColdStartTarget {
  final String location;
  final Object? extra;

  const NotificationColdStartTarget(this.location, [this.extra]);
}

/// Jadwal sholat dari topic FCM / topic internal (bila `tipe_redirect` kosong di payload).
bool notificationImpliesJadwalSholat(NotificationModel notification) {
  final tipe = notification.tipeRedirect?.toLowerCase().trim() ?? '';
  if (tipe == 'prayer' || tipe == 'jadwal' || tipe == 'sholat') {
    return true;
  }
  final topic = notification.topic.toLowerCase().trim();
  if (topic.isEmpty || topic == 'all') return false;
  return topic.contains('prayer') ||
      topic.contains('sholat') ||
      topic.contains('jadwal');
}

/// Samakan aturan dengan [openNotificationTargetWithRouter]; WebView pakai `/webview` (cabang home).
NotificationColdStartTarget? coldStartTargetForNotification(NotificationModel notification) {
  if (notificationImpliesJadwalSholat(notification)) {
    return const NotificationColdStartTarget('/jadwal-sholat');
  }

  final redirect = notification.urlRedirect?.trim() ?? '';
  final hasUrl = redirect.isNotEmpty;
  final tipe = notification.tipeRedirect?.toLowerCase().trim() ?? '';

  switch (tipe) {
    case 'news':
    case 'berita':
      if (hasUrl) {
        return NotificationColdStartTarget('/berita/detail', {'slug': redirect});
      }
      return const NotificationColdStartTarget('/berita');
    case 'event':
    case 'agenda':
      if (hasUrl) {
        return NotificationColdStartTarget('/agenda/detail', {'slug': redirect});
      }
      return const NotificationColdStartTarget('/agenda');
    case 'web':
      if (hasUrl) {
        return NotificationColdStartTarget('/webview', {
          'url': redirect,
          'title': notification.title,
        });
      }
      return null;
    case 'letter':
      if (hasUrl) {
        return NotificationColdStartTarget('/webview', {
          'url': redirect,
          'title': notification.title,
        });
      }
      return null;
    case 'internal':
      if (hasUrl) {
        final loc = redirect.startsWith('/') ? redirect : '/$redirect';
        return NotificationColdStartTarget(loc);
      }
      return null;
    default:
      if (!hasUrl) {
        return null;
      }
      if (redirect.startsWith('http')) {
        return NotificationColdStartTarget('/webview', {
          'url': redirect,
          'title': notification.title,
        });
      }
      if (redirect.startsWith('/')) {
        return NotificationColdStartTarget(redirect);
      }
      return NotificationColdStartTarget('/$redirect');
  }
}

/// Dari [BuildContext] (mis. halaman daftar notifikasi).
void openNotificationTarget(BuildContext context, NotificationModel notification) {
  unawaited(openNotificationTargetWithRouter(GoRouter.of(context), notification));
}

/// Navigasi via [GoRouter] langsung — dipakai saat tap FCM / notifikasi sistem (tanpa context).
///
/// - Berita / agenda + URL kosong → daftar `/berita` atau `/agenda`.
/// - Web (+ surat/letter) + URL ada → WebView in-app; URL kosong → home `/`.
/// - Lainnya + URL kosong → home `/`.
///
/// Jika belum login: simpan tujuan ke [PendingAuthRedirect] lalu arahkan ke onboarding/login.
Future<void> openNotificationTargetWithRouter(GoRouter router, NotificationModel notification) async {
  if (!await AuthLocalService().isLoggedIn()) {
    final t = coldStartTargetForNotification(notification);
    final location = t?.location ?? '/';
    final extra = t?.extra;
    await PendingAuthRedirect.save(location, extra);
    router.go(await AuthLocalService().resolveInitialLocation());
    return;
  }

  if (notificationImpliesJadwalSholat(notification)) {
    router.go('/jadwal-sholat');
    return;
  }

  final redirect = notification.urlRedirect?.trim() ?? '';
  final hasUrl = redirect.isNotEmpty;
  final tipe = notification.tipeRedirect?.toLowerCase().trim() ?? '';

  final shellPath = router.state.uri.path;
  final webviewLoc = webviewShellLocationForPath(shellPath);

  void goHome() => router.go('/');

  switch (tipe) {
    case 'news':
    case 'berita':
      if (hasUrl) {
        router.go('/berita/detail', extra: {'slug': redirect});
      } else {
        router.go('/berita');
      }
      break;
    case 'event':
    case 'agenda':
      if (hasUrl) {
        router.go('/agenda/detail', extra: {'slug': redirect});
      } else {
        router.go('/agenda');
      }
      break;
    case 'web':
      if (hasUrl) {
        router.go(
          webviewLoc,
          extra: {'url': redirect, 'title': notification.title},
        );
      } else {
        goHome();
      }
      break;
    case 'letter':
      if (hasUrl) {
        router.go(
          webviewLoc,
          extra: {'url': redirect, 'title': notification.title},
        );
      } else {
        goHome();
      }
      break;
    case 'internal':
      if (hasUrl) {
        router.go(redirect.startsWith('/') ? redirect : '/$redirect');
      } else {
        goHome();
      }
      break;
    default:
      if (!hasUrl) {
        goHome();
        break;
      }
      if (redirect.startsWith('http')) {
        router.go(
          webviewLoc,
          extra: {'url': redirect, 'title': notification.title},
        );
      } else if (redirect.startsWith('/')) {
        router.go(redirect);
      } else {
        router.go('/$redirect');
      }
      break;
  }
}

/// Tunggu [bindAppGoRouter] dari [MyApp], lalu navigasi (cold start / tap sebelum router siap).
void scheduleOpenNotificationTarget(NotificationModel notification, {int maxAttempts = 120}) {
  var left = maxAttempts;
  void attempt() {
    final router = appGoRouterOrNull;
    if (router != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(openNotificationTargetWithRouter(router, notification));
      });
      return;
    }
    if (left-- <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => attempt());
  }

  WidgetsBinding.instance.addPostFrameCallback((_) => attempt());
}
