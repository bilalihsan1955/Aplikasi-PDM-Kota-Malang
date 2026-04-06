import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import 'api_service.dart';
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
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pdm_malang_channel',
      'PDM Malang Notifications',
      description: 'Notifikasi untuk PDM Malang',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
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
      'PDM Malang Notifications',
      channelDescription: 'Notifikasi untuk PDM Malang',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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
      message.notification?.title ?? 'PDM Malang',
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
