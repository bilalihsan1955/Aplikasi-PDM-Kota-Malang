import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import 'api_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

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

  // Current FCM token
  String? _currentToken;

  // Inisialisasi FCM
  Future<void> initialize() async {
    // Request permission untuk iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
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

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get and save FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveFcmToken(token);
      print('FCM Token: $token');
    }

    // Subscribe ke topic default hanya sekali saat pertama aplikasi dijalankan
    await _subscribeToDefaultTopicsIfFirstLaunch();

    // Re-subscribe to saved topics (untuk install ulang / token refresh)
    await resubscribeToSavedTopics();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      await _saveFcmToken(newToken);
      // Re-subscribe to all topics with new token
      await resubscribeToSavedTopics();
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotificationTap);

    // Handle notification when app is opened from terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundNotificationTap(initialMessage);
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
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
      payload: jsonEncode(message.data),
    );
  }

  // Handle notification tap from background/terminated
  void _handleBackgroundNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.notification?.title}');
    
    final notification = _convertToNotificationModel(message);
    onNotificationTapped?.call(notification);
  }

  // Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: data['title'] ?? '',
        body: data['body'] ?? '',
        type: data['type'] ?? 'general',
        timestamp: DateTime.now(),
        data: data,
      );
      onNotificationTapped?.call(notification);
    }
  }

  // Convert RemoteMessage to NotificationModel
  NotificationModel _convertToNotificationModel(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'general',
      timestamp: DateTime.now(),
      data: message.data,
    );
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

  /// Update FCM token ke backend (untuk user yang login)
  Future<bool> updateTokenToBackend(String userToken) async {
    try {
      final fcmToken = await getToken();
      if (fcmToken == null) return false;

      final response = await _apiService.updateFcmToken(
        userToken: userToken,
        fcmToken: fcmToken,
      );

      return response.success;
    } catch (e) {
      print('Error updating FCM token to backend: $e');
      return false;
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
