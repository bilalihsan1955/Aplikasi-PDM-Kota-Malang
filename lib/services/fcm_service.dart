import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import 'api_service.dart';
import 'prayer_alarm_reminder_prefs.dart';
import 'prayer_schedule_local_cache.dart';
import 'jadwal_permission_onboarding_prefs.dart';
import 'auth/auth_local_service.dart';
import 'fcm_device_payload.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  static bool _notificationOpenListenerRegistered = false;

  /// [getInitialMessage] sudah dipakai di `main()` untuk [GoRouter.initialLocation]; jangan navigasi ulang.
  static bool _initialLaunchMessageConsumed = false;

  static void markInitialLaunchMessageConsumed() {
    _initialLaunchMessageConsumed = true;
  }

  static NotificationModel notificationModelFromRemoteMessage(RemoteMessage message) {
    return FCMService()._convertToNotificationModel(message);
  }

  /// Tap saat app dari **background** (notifikasi sistem FCM).
  /// [getInitialMessage] jangan dipanggil di sini — panggil [deliverInitialMessageWhenReady]
  /// setelah frame pertama agar data intent terbaca benar di Android.
  static void registerNotificationOpenListener() {
    if (_notificationOpenListenerRegistered) return;
    _notificationOpenListenerRegistered = true;
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      FCMService()._tapFromRemoteMessage(m);
    });
  }

  /// Panggil setelah [MaterialApp] / router siap (satu kali per cold start — jangan panggil ulang).
  static Future<void> deliverInitialMessageWhenReady() async {
    if (_initialLaunchMessageConsumed) return;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      FCMService()._tapFromRemoteMessage(initial);
    }
  }

  /// Cold start dari tap notifikasi **lokal** (bukan FCM), mis. pengingat jadwal — isi tray.
  static Future<NotificationModel?> notificationModelFromLocalNotificationLaunch() async {
    final i = FCMService();
    await i._initializeLocalNotifications();
    final details = await i._localNotifications.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    final payload = details!.notificationResponse?.payload;
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      return NotificationModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (e, st) {
      // ignore: avoid_print
      print('[FCM] notificationModelFromLocalNotificationLaunch: $e\n$st');
      return null;
    }
  }

  // --- Gate: izin lokasi diminta setelah dialog izin notifikasi selesai ---
  static final List<Completer<void>> _locationAfterNotifWaiters = [];
  static bool _locationGateReleased = false;

  static void releaseLocationGate() {
    if (_locationGateReleased) return;
    _locationGateReleased = true;
    for (final c in _locationAfterNotifWaiters) {
      if (!c.isCompleted) c.complete();
    }
    _locationAfterNotifWaiters.clear();
  }

  /// Panggil sebelum [initializeAfterLogin] (mis. setelah login) atau di awal alur FCM.
  /// Menutup kembali gate jika sebelumnya [releaseLocationGate] sudah jalan saat belum login,
  /// agar izin lokasi benar-benar menunggu dialog notifikasi selesai.
  static void armLocationGateBeforeNotificationPrompt() {
    _locationGateReleased = false;
  }

  /// [PrayerTimeService] menunggu ini sebelum [Geolocator.requestPermission].
  static Future<void> waitUntilNotificationFlowDoneForLocation() async {
    if (_locationGateReleased) return;
    final c = Completer<void>();
    _locationAfterNotifWaiters.add(c);
    return c.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => releaseLocationGate(),
    );
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  bool _localNotifsInitialized = false;

  /// Saluran khusus pengingat sholat (IMPORTANCE_MAX + USAGE_ALARM). ID baru agar tidak terkunci ke channel lama.
  static const String _prayerReminderChannelId = 'pdm_malang_prayer_alarms_v2';

  /// ID notifikasi lokal pengingat sholat: 5 wajib × 2 (teks “5 mnt” + masuk waktu).
  static const int _prayerReminderIdStart = 92010;

  /// Teks “5 menit lagi”, dijadwalkan tepat 5 menit sebelum waktu sholat.
  static const Duration _prayerAdvanceReminderScheduleLead = Duration(minutes: 5);

  /// Notifikasi “masuk waktu” dijadwalkan 2 menit sebelum jam sholat
  /// agar tetap terasa tepat waktu saat ada delay sistem/OEM.
  static const Duration _prayerOnTimeScheduleAdvance = Duration(minutes: 0);

  static const int _prayerReminderSlotCount = 10;
  /// ID lama penjadwalan tes (dibersihkan saat pembatalan pengingat).
  static const int _legacyPrayerDiagnosticNotificationId = 92001;
  /// ID notifikasi uji lama (dibersihkan setelah fitur tes dihapus).
  static const int _legacyUiTestNotificationId = 91001;

  /// Argumen terakhir [syncPrayerScheduleNotifications] — dipakai ulang setelah user kembali dari pengaturan izin.
  String? _lastPrayerSyncCity;
  List<(String name, String timeRaw)>? _lastPrayerSyncPrayers;

  // Storage keys
  static const String _subscribedTopicsKey = 'subscribed_topics';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _initialSubscribeDoneKey = 'fcm_initial_subscribe_done';

  /// Topic default yang di-subscribe sekali saat pertama aplikasi dijalankan
  static const List<String> _defaultTopics = ['general', 'news', 'agenda', 'announcement'];

  // Callback untuk ketika notifikasi diterima
  Function(NotificationModel)? onNotificationReceived;
  Function(NotificationModel)? onNotificationTapped;

  /// Tap sebelum [onNotificationTapped] diset (mis. cold start dari terminated).
  NotificationModel? _pendingOpenedNotification;

  // Current FCM token
  String? _currentToken;
  String? _lastSyncedFcmTokenPosted;
  DateTime? _lastFcmTokenPostAt;

  bool _fcmAfterLoginSetupDone = false;
  bool _fcmMessageStreamsAttached = false;
  Future<void>? _initializeAfterLoginInFlight;

  /// Setup FCM + izin notifikasi. Hanya dipanggil setelah user login (atau cold start dengan sesi).
  Future<void> initializeAfterLogin() async {
    if (_fcmAfterLoginSetupDone) {
      await syncRegisteredTokenToBackend();
      return;
    }
    if (_initializeAfterLoginInFlight != null) {
      await _initializeAfterLoginInFlight;
      await syncRegisteredTokenToBackend();
      return;
    }
    _initializeAfterLoginInFlight = _runInitializeAfterLogin();
    try {
      await _initializeAfterLoginInFlight;
    } finally {
      _initializeAfterLoginInFlight = null;
    }
  }

  Future<void> _runInitializeAfterLogin() async {
    try {
      armLocationGateBeforeNotificationPrompt();

      final NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      // Izin lokasi (jadwal sholat) menunggu sampai dialog notifikasi selesai.
      releaseLocationGate();

      await _initializeLocalNotifications();

      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveFcmToken(token);
        print('FCM Token: $token');
      }

      await syncRegisteredTokenToBackend();

      await _subscribeToDefaultTopicsIfFirstLaunch();

      await resubscribeToSavedTopics();

      if (!_fcmMessageStreamsAttached) {
        _firebaseMessaging.onTokenRefresh.listen((newToken) async {
          print('FCM Token refreshed: $newToken');
          await _saveFcmToken(newToken);
          await resubscribeToSavedTopics();
          await syncRegisteredTokenToBackend();
        });

        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        _fcmMessageStreamsAttached = true;
      }

      _fcmAfterLoginSetupDone = true;
    } catch (e, st) {
      releaseLocationGate();
      // ignore: avoid_print
      print('[FCM] initializeAfterLogin error: $e\n$st');
    }
  }

  void _dispatchNotificationOpened(NotificationModel notification) {
    if (onNotificationTapped != null) {
      onNotificationTapped!(notification);
    } else {
      _pendingOpenedNotification = notification;
    }
  }

  /// Panggil dari [MyApp] setelah [onNotificationTapped] di-set.
  void consumePendingNotificationOpen() {
    final p = _pendingOpenedNotification;
    _pendingOpenedNotification = null;
    if (p != null) {
      onNotificationTapped?.call(p);
    }
  }

  void _tapFromRemoteMessage(RemoteMessage message) {
    final notification = _convertToNotificationModel(message);
    final url = notification.urlRedirect?.trim();
    final tipe = notification.tipeRedirect?.trim();
    if ((url == null || url.isEmpty) && (tipe == null || tipe.isEmpty)) {
      // ignore: avoid_print
      print(
        '[FCM] Tap: tidak ada url_redirect dan tipe_redirect — diarahkan ke home. '
        'data keys: ${message.data.keys.toList()}',
      );
    }
    _dispatchNotificationOpened(notification);
    onNotificationReceived?.call(notification);
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    if (_localNotifsInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_stat_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    // Create notification channels for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pdm_malang_channel',
      'Makotamu',
      description: 'Notifikasi Makotamu',
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);

    // Wajib: pengingat sholat memakai channel ini ([_prayerReminderChannelId]). Tanpa createChannel,
    // AlarmManager tetap memicu receiver tetapi notifikasi sering tidak tampil saat app terminated.
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _prayerReminderChannelId,
        'Pengingat waktu sholat',
        description: 'Alarm dan pengingat jadwal sholat (prioritas tinggi).',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );

    _localNotifsInitialized = true;
  }

  /// Izin + init plugin untuk penjadwalan notifikasi lokal (jadwal sholat).
  /// `false` = izin notifikasi ditolak user.
  Future<bool> ensureLocalNotificationsReadyForTest() async {
    await _initializeLocalNotifications();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      try {
        final alreadyOn = await android?.areNotificationsEnabled();
        if (alreadyOn == true) return true;
      } catch (_) {}
      final granted = await android?.requestNotificationsPermission();
      if (granted == false) return false;
      return true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final ok = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (ok == false) return false;
      return true;
    }
    return true;
  }

  /// Android: jika alarm presisi belum diizinkan, buka layar pengaturan sistem.
  /// Dipanggil saat membuka halaman jadwal sholat (bukan first-open).
  Future<void> openAndroidAlarmReminderSettingsIfDenied() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _initializeLocalNotifications();
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final can = await android?.canScheduleExactNotifications();
    if (can == true) return;
    await android?.requestExactAlarmsPermission();
  }

  /// Pertama buka Jadwal (Android): izin notifikasi → jeda → izin alarm tepat → cek ulang & buka pengaturan jika perlu.
  Future<void> runJadwalPageAndroidPermissionOnboarding() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await _initializeLocalNotifications();
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final firstJadwal = !await JadwalPermissionOnboardingPrefs.isDone();
    if (firstJadwal) {
      await android?.requestNotificationsPermission();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await android?.requestExactAlarmsPermission();
      await JadwalPermissionOnboardingPrefs.markDone();
    } else {
      try {
        final enabled = await android?.areNotificationsEnabled();
        if (enabled == false) {
          await android?.requestNotificationsPermission();
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
      } catch (e) {
        // ignore: avoid_print
        print('[FCM] areNotificationsEnabled: $e');
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    await openAndroidAlarmReminderSettingsIfDenied();
  }

  /// Panggil setelah app kembali ke foreground (mis. dari layar izin alarm) agar jadwal dijadwalkan ulang.
  Future<void> replayLastPrayerScheduleNotificationsIfAny() async {
    if (kIsWeb) return;
    final city = _lastPrayerSyncCity;
    final prayers = _lastPrayerSyncPrayers;
    if (city == null || prayers == null) return;
    await syncPrayerScheduleNotifications(city: city, prayers: prayers);
  }

  /// Judul & isi saat **masuk waktu** sholat.
  static String _cityTitleCase(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    return t
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  static ({String title, String body}) prayerScheduleReminderNotificationCopy({
    required String prayerName,
    required String timeDot,
    required String city,
  }) {
    final name = prayerName.trim().isEmpty ? 'Sholat' : prayerName.trim();
    final when = timeDot.trim().isEmpty ? '—.–' : timeDot.trim();
    final place = city.trim().isEmpty ? 'Lokasi Anda' : _cityTitleCase(city);
    final title = 'Waktu $name';
    final body = '$when · $place\n'
        'Tetap sholat di awal waktu.';
    return (title: title, body: body);
  }

  /// Judul **5 menit lagi** (salinan pengguna); penjadwalan aktual lihat [_prayerAdvanceReminderScheduleLead].
  static ({String title, String body}) prayerFiveMinuteBeforeNotificationCopy({
    required String prayerName,
    required String timeDot,
    required String city,
  }) {
    final name = prayerName.trim().isEmpty ? 'Sholat' : prayerName.trim();
    final when = timeDot.trim().isEmpty ? '—.–' : timeDot.trim();
    final place = city.trim().isEmpty ? 'Lokasi Anda' : _cityTitleCase(city);
    final title = '5 menit lagi · $name';
    final body = 'Waktu $name pukul $when · $place\n'
        'Siapkan diri untuk sholat tepat waktu.';
    return (title: title, body: body);
  }

  (int, int)? _parsePrayerClock(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final parts = s.replaceAll('.', ':').split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return (h, m);
  }

  String _clockToDot(String raw) {
    final p = _parsePrayerClock(raw);
    if (p == null) return raw.trim();
    return '${p.$1.toString().padLeft(2, '0')}.${p.$2.toString().padLeft(2, '0')}';
  }

  /// Hanya slot jadwal sholat harian (92010–92019).
  Future<void> _cancelPrayerReminderSlotsOnly() async {
    if (kIsWeb) return;
    await _initializeLocalNotifications();
    for (var i = 0; i < _prayerReminderSlotCount; i++) {
      try {
        await _localNotifications.cancel(_prayerReminderIdStart + i);
      } catch (e, st) {
        // ignore: avoid_print
        print('[FCM] cancel prayer slot $i: $e\n$st');
      }
    }
  }

  /// Batalkan semua slot pengingat jadwal + ID tes lama bila masih tersisa di perangkat.
  Future<void> cancelAllPrayerScheduleReminders() async {
    if (kIsWeb) return;
    await _cancelPrayerReminderSlotsOnly();
    try {
      await _localNotifications.cancel(_legacyPrayerDiagnosticNotificationId);
    } catch (e, st) {
      // ignore: avoid_print
      print('[FCM] cancel legacy test id: $e\n$st');
    }
  }

  Future<void> _cancelLegacyUiTestNotification() async {
    if (kIsWeb) return;
    try {
      await _initializeLocalNotifications();
      await _localNotifications.cancel(_legacyUiTestNotificationId);
    } catch (_) {}
  }

  /// Membatalkan notifikasi uji lama (ID 91001) bila masih tertinggal di perangkat.
  Future<void> cancelLegacyUiTestNotificationIfAny() async {
    await _cancelLegacyUiTestNotification();
  }

  /// Jadwalkan ulang alarm dari cache hari ini (sebelum API jalan) agar tray tetap punya jadwal saat app terminasi.
  Future<void> reschedulePrayerAlarmsFromLocalCacheIfValid() async {
    if (kIsWeb) return;
    final cached = await PrayerScheduleLocalCache.loadIfToday();
    if (cached == null) return;
    await syncPrayerScheduleNotifications(
      city: cached.city,
      prayers: cached.prayers,
    );
  }

  /// Sinkronkan notifikasi lokal hari ini: salinan “5 menit” (jadwal 5 mnt) + masuk waktu (jadwal 2 mnt lebih awal).
  /// Panggil setelah jadwal harian berhasil dimuat. Ganti jadwal lama.
  Future<void> syncPrayerScheduleNotifications({
    required String city,
    required List<(String name, String timeRaw)> prayers,
  }) async {
    if (kIsWeb) return;
    if (!await PrayerAlarmReminderPrefs.isEnabled()) {
      _lastPrayerSyncCity = null;
      _lastPrayerSyncPrayers = null;
      await PrayerScheduleLocalCache.clear();
      await cancelAllPrayerScheduleReminders();
      return;
    }
    if (prayers.length * 2 > _prayerReminderSlotCount) return;
    _lastPrayerSyncCity = city;
    _lastPrayerSyncPrayers = List<(String name, String timeRaw)>.from(prayers);

    final permitted = await ensureLocalNotificationsReadyForTest();
    if (!permitted) {
      await cancelAllPrayerScheduleReminders();
      return;
    }
    await _initializeLocalNotifications();
    await _ensureAndroidExactAlarmForPrayerReminders();
    await _cancelPrayerReminderSlotsOnly();

    final now = tz.TZDateTime.now(tz.local);
    const oneDay = Duration(days: 1);
    for (var i = 0; i < prayers.length; i++) {
      final name = prayers[i].$1;
      final raw = prayers[i].$2;
      final clock = _parsePrayerClock(raw);
      if (clock == null) continue;
      final atToday = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        clock.$1,
        clock.$2,
      );
      final at = atToday.isAfter(now) ? atToday : atToday.add(oneDay);
      final timeDot = _clockToDot(raw);
      final before = at.subtract(_prayerAdvanceReminderScheduleLead);

      if (before.isAfter(now)) {
        final pre = prayerFiveMinuteBeforeNotificationCopy(
          prayerName: name,
          timeDot: timeDot,
          city: city,
        );
        await _zonedSchedulePrayerReminder(
          id: _prayerReminderIdStart + i * 2,
          when: before,
          title: pre.title,
          body: pre.body,
        );
      }

      var onWhen = at.subtract(_prayerOnTimeScheduleAdvance);
      if (!onWhen.isAfter(now) && at.isAfter(now)) {
        var bump = now.add(const Duration(seconds: 12));
        if (!bump.isBefore(at)) {
          bump = at.subtract(const Duration(seconds: 2));
        }
        onWhen = bump;
      }
      if (at.isAfter(now) && onWhen.isAfter(now)) {
        final copy = prayerScheduleReminderNotificationCopy(
          prayerName: name,
          timeDot: timeDot,
          city: city,
        );
        await _zonedSchedulePrayerReminder(
          id: _prayerReminderIdStart + i * 2 + 1,
          when: onWhen,
          title: copy.title,
          body: copy.body,
        );
      }
    }
    await PrayerScheduleLocalCache.save(city: city, prayers: prayers);
  }

  Future<void> _zonedSchedulePrayerReminder({
    required int id,
    required tz.TZDateTime when,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _prayerReminderChannelId,
      'Pengingat waktu sholat',
      channelDescription:
          'Alarm dan reminder jadwal sholat; memakai saluran prioritas tinggi',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      icon: 'ic_stat_notification',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    Future<void> doSchedule(AndroidScheduleMode mode) =>
        _localNotifications.zonedSchedule(
          id,
          title,
          body,
          when,
          details,
          androidScheduleMode: mode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: jsonEncode({
            'title': title,
            'body': body,
            'topic': 'prayer_schedule',
            'tipe_redirect': 'prayer',
          }),
        );

    // Urutan untuk stabilitas notifikasi saat process mati:
    // 1) alarmClock (sering paling kuat saat app di-swipe/terminated),
    // 2) exactAllowWhileIdle,
    // 3) inexactAllowWhileIdle (terakhir).
    try {
      await doSchedule(AndroidScheduleMode.alarmClock);
      // ignore: avoid_print
      print('[FCM] zonedSchedule mode=alarmClock id=$id when=$when');
    } catch (e) {
      try {
        // ignore: avoid_print
        print('[FCM] zonedSchedule alarmClock gagal, coba exactAllowWhileIdle: $e');
        await doSchedule(AndroidScheduleMode.exactAllowWhileIdle);
        // ignore: avoid_print
        print('[FCM] zonedSchedule mode=exactAllowWhileIdle id=$id when=$when');
      } catch (e2) {
        // ignore: avoid_print
        print('[FCM] zonedSchedule exact gagal, pakai inexactAllowWhileIdle: $e2');
        await doSchedule(AndroidScheduleMode.inexactAllowWhileIdle);
        // ignore: avoid_print
        print('[FCM] zonedSchedule mode=inexactAllowWhileIdle id=$id when=$when');
      }
    }
  }

  /// Pastikan alarm tepat boleh dijadwalkan (terminasi proses / Doze). USE_EXACT_ALARM memperkuat ini.
  Future<void> _ensureAndroidExactAlarmForPrayerReminders() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    try {
      final can = await android.canScheduleExactNotifications();
      if (can == true) return;
      await android.requestExactAlarmsPermission();
    } catch (e) {
      // ignore: avoid_print
      print('[FCM] _ensureAndroidExactAlarmForPrayerReminders: $e');
    }
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.notification?.title}');

    final notification = _convertToNotificationModel(message);
    
    // Show local notification
    _showLocalNotification(message);

    // Trigger callback
    onNotificationReceived?.call(notification);
  }

  /// Payload untuk tap notifikasi lokal: gabung `data` FCM + title/body dari blok notification.
  Map<String, dynamic> _localNotificationPayloadMap(RemoteMessage message) {
    final out = <String, dynamic>{};
    for (final e in message.data.entries) {
      out[e.key] = e.value;
    }
    final n = message.notification;
    if (n?.title != null && n!.title!.trim().isNotEmpty) {
      out.putIfAbsent('title', () => n.title!);
    }
    if (n?.body != null && n!.body!.trim().isNotEmpty) {
      out.putIfAbsent('body', () => n.body!);
    }
    return out;
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pdm_malang_channel',
      'Makotamu',
      channelDescription: 'Notifikasi Makotamu',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_notification',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Makotamu',
      message.notification?.body ?? '',
      details,
      payload: jsonEncode(_localNotificationPayloadMap(message)),
    );
  }

  // Handle local notification tap (foreground tray)
  void _handleLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;
    try {
      final decoded = jsonDecode(response.payload!);
      if (decoded is! Map) return;
      final map = Map<String, dynamic>.from(decoded);
      final notification = NotificationModel.fromJson(map);
      _dispatchNotificationOpened(notification);
    } catch (e) {
      // ignore: avoid_print
      print('[FCM] Tap payload parse error: $e');
    }
  }

  Map<String, dynamic> _buildJsonMapFromRemoteMessage(RemoteMessage message) {
    final raw = <String, dynamic>{};
    for (final e in message.data.entries) {
      raw[e.key] = e.value;
    }
    for (final key in ['notification', 'data', 'payload']) {
      final v = raw[key];
      if (v is String) {
        final t = v.trim();
        if (t.startsWith('{') && t.endsWith('}')) {
          try {
            final decoded = jsonDecode(t);
            if (decoded is Map) {
              raw[key] = Map<String, dynamic>.from(
                decoded.map((k, val) => MapEntry(k.toString(), val)),
              );
            }
          } catch (_) {}
        }
      }
    }
    final n = message.notification;
    if (n != null) {
      final existing = raw['notification'];
      if (existing is! Map) {
        raw['notification'] = <String, dynamic>{
          'title': n.title,
          'body': n.body,
        };
      } else {
        final nm = Map<String, dynamic>.from(existing);
        nm.putIfAbsent('title', () => n.title);
        nm.putIfAbsent('body', () => n.body);
        raw['notification'] = nm;
      }
    }
    return raw;
  }

  NotificationModel _convertToNotificationModel(RemoteMessage message) {
    return NotificationModel.fromJson(_buildJsonMapFromRemoteMessage(message));
  }

  // ==================== TOPIC SUBSCRIPTION (Public - Tanpa Login) ====================

  /// Subscribe to topic dan kirim ke backend (public)
  Future<bool> subscribeToTopicPublic(String topic) async {
    try {
      // Get FCM token
      final token = await getToken();
      if (token == null) {
        print('FCM token is null');
        return false;
      }

      // Subscribe di Firebase
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to Firebase topic: $topic');

      // Kirim ke backend API
      final response = await _apiService.subscribeToTopicPublic(
        fcmToken: token,
        topic: topic,
      );

      if (response.success) {
        // Simpan ke local storage
        await _saveSubscribedTopic(topic);
        print('Successfully subscribed to topic: $topic');
        return true;
      } else {
        print('Failed to subscribe to backend: ${response.message}');
        // Tetap return true karena sudah subscribe di Firebase
        await _saveSubscribedTopic(topic);
        return true;
      }
    } catch (e) {
      print('Error subscribing to topic: $e');
      return false;
    }
  }

  /// Unsubscribe from topic dan hapus dari backend (public)
  Future<bool> unsubscribeFromTopicPublic(String topic) async {
    try {
      // Get FCM token
      final token = await getToken();
      if (token == null) {
        print('FCM token is null');
        return false;
      }

      // Unsubscribe di Firebase
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from Firebase topic: $topic');

      // Hapus dari backend API
      final response = await _apiService.unsubscribeFromTopicPublic(
        fcmToken: token,
        topic: topic,
      );

      if (response.success) {
        // Hapus dari local storage
        await _removeSubscribedTopic(topic);
        print('Successfully unsubscribed from topic: $topic');
        return true;
      } else {
        print('Failed to unsubscribe from backend: ${response.message}');
        // Tetap return true karena sudah unsubscribe di Firebase
        await _removeSubscribedTopic(topic);
        return true;
      }
    } catch (e) {
      print('Error unsubscribing from topic: $e');
      return false;
    }
  }

  // ==================== TOPIC SUBSCRIPTION (Authenticated - Untuk User Login) ====================

  /// Subscribe to topic dengan authentication (untuk user yang sudah login)
  Future<bool> subscribeToTopicAuth(String topic, String userToken) async {
    try {
      // Subscribe di Firebase
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to Firebase topic: $topic');

      // Kirim ke backend API dengan auth
      final response = await _apiService.subscribeToTopicAuth(
        userToken: userToken,
        topic: topic,
      );

      if (response.success) {
        await _saveSubscribedTopic(topic);
        print('Successfully subscribed to topic with auth: $topic');
        return true;
      } else {
        print('Failed to subscribe to backend: ${response.message}');
        await _saveSubscribedTopic(topic);
        return true;
      }
    } catch (e) {
      print('Error subscribing to topic: $e');
      return false;
    }
  }

  /// Unsubscribe from topic dengan authentication
  Future<bool> unsubscribeFromTopicAuth(String topic, String userToken) async {
    try {
      // Unsubscribe di Firebase
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from Firebase topic: $topic');

      // Hapus dari backend API dengan auth
      final response = await _apiService.unsubscribeFromTopicAuth(
        userToken: userToken,
        topic: topic,
      );

      if (response.success) {
        await _removeSubscribedTopic(topic);
        print('Successfully unsubscribed from topic with auth: $topic');
        return true;
      } else {
        print('Failed to unsubscribe from backend: ${response.message}');
        await _removeSubscribedTopic(topic);
        return true;
      }
    } catch (e) {
      print('Error unsubscribing from topic: $e');
      return false;
    }
  }

  // ==================== LOCAL STORAGE ====================

  /// Simpan topic yang sudah di-subscribe ke local storage
  Future<void> _saveSubscribedTopic(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final topics = await getSubscribedTopics();
    if (!topics.contains(topic)) {
      topics.add(topic);
      await prefs.setStringList(_subscribedTopicsKey, topics);
    }
  }

  /// Hapus topic dari local storage
  Future<void> _removeSubscribedTopic(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final topics = await getSubscribedTopics();
    topics.remove(topic);
    await prefs.setStringList(_subscribedTopicsKey, topics);
  }

  /// Get list topic yang sudah di-subscribe
  Future<List<String>> getSubscribedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_subscribedTopicsKey) ?? [];
  }

  /// Check apakah sudah subscribe ke topic tertentu
  Future<bool> isSubscribedToTopic(String topic) async {
    final topics = await getSubscribedTopics();
    return topics.contains(topic);
  }

  /// Simpan FCM token ke local storage
  Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
    _currentToken = token;
  }

  // ==================== TOKEN MANAGEMENT ====================

  /// Get FCM token
  Future<String?> getToken() async {
    if (_currentToken != null) return _currentToken;
    
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_fcmTokenKey);
    
    if (savedToken != null) {
      _currentToken = savedToken;
      return savedToken;
    }

    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveFcmToken(token);
    }
    return token;
  }

  /// POST `/fcm/token` jika user sudah login (Bearer + body `fcm_token`).
  Future<bool> updateTokenToBackend(String userToken) async {
    try {
      final fcmToken = await getToken();
      if (fcmToken == null) return false;

      final device = await buildFcmDevicePayload();

      final response = await _apiService.updateFcmToken(
        userToken: userToken,
        fcmToken: fcmToken,
        device: device,
      );

      return response.success;
    } catch (e) {
      print('Error updating FCM token to backend: $e');
      return false;
    }
  }

  /// Kirim token ke backend hanya jika sesi login lengkap (setelah login / cold start login).
  Future<void> syncRegisteredTokenToBackend() async {
    try {
      final auth = AuthLocalService();
      if (!await auth.isLoggedIn()) return;
      final userToken = await auth.getToken();
      if (userToken == null || userToken.trim().isEmpty) return;
      final fcmToken = await getToken();
      if (fcmToken == null) return;
      final now = DateTime.now();
      if (_lastSyncedFcmTokenPosted == fcmToken &&
          _lastFcmTokenPostAt != null &&
          now.difference(_lastFcmTokenPostAt!) < const Duration(seconds: 5)) {
        return;
      }
      final ok = await updateTokenToBackend(userToken.trim());
      if (ok) {
        _lastSyncedFcmTokenPosted = fcmToken;
        _lastFcmTokenPostAt = now;
      }
    } catch (e) {
      print('[FCM] syncRegisteredTokenToBackend: $e');
    }
  }

  /// Hapus FCM token dari backend (saat logout)
  Future<bool> deleteTokenFromBackend(String userToken) async {
    try {
      final response = await _apiService.deleteFcmToken(
        userToken: userToken,
      );

      if (response.success) {
        // Clear subscribed topics
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_subscribedTopicsKey);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting FCM token from backend: $e');
      return false;
    }
  }

  /// Subscribe ke topic default hanya sekali saat pertama aplikasi dijalankan
  Future<void> _subscribeToDefaultTopicsIfFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool(_initialSubscribeDoneKey) ?? false;
      if (done) return;

      for (final topic in _defaultTopics) {
        await subscribeToTopicPublic(topic);
      }
      await prefs.setBool(_initialSubscribeDoneKey, true);
      print('Initial FCM subscribe to default topics done');
    } catch (e) {
      print('Error initial FCM subscribe: $e');
    }
  }

  /// Re-subscribe to all saved topics (useful after app restart)
  Future<void> resubscribeToSavedTopics() async {
    try {
      final topics = await getSubscribedTopics();
      for (final topic in topics) {
        await _firebaseMessaging.subscribeToTopic(topic);
        print('Re-subscribed to topic: $topic');
      }
    } catch (e) {
      print('Error re-subscribing to topics: $e');
    }
  }
}
