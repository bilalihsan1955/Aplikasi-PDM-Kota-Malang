import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../models/notification_model.dart';
import '../services/fcm_service.dart';

class NotificationViewModel extends ChangeNotifier {
  FCMService? _fcmService;
  
  List<NotificationModel> _notifications = [];
  String _selectedFilter = 'Semua';
  
  List<NotificationModel> get notifications => _notifications;
  String get selectedFilter => _selectedFilter;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  final List<String> filters = [
    'Semua',
    'Berita',
    'Agenda',
    'Pengumuman',
  ];

  NotificationViewModel() {
    _initializeFCM();
    _loadDummyNotifications();
  }

  // Initialize FCM
  Future<void> _initializeFCM() async {
    try {
      _fcmService = FCMService();
      await _fcmService!.initialize();
      
      // Set callbacks
      _fcmService!.onNotificationReceived = (notification) {
        _addNotification(notification);
      };
      
      _fcmService!.onNotificationTapped = (notification) {
        // Handle navigation based on notification type
        markAsRead(notification.id);
      };
      
      print('FCM initialized successfully');
    } catch (e) {
      // Firebase not initialized - skip FCM setup
      // App will work with dummy notifications only
      print('FCM initialization skipped: $e');
      _fcmService = null;
    }
  }

  // Load dummy notifications for demo
  void _loadDummyNotifications() {
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'Kajian Akbar Ramadhan 1446 H',
        body: 'Undangan menghadiri kajian akbar dalam rangka menyambut bulan suci Ramadhan.',
        type: 'agenda',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Pembukaan Kantor Cabang Baru',
        body: 'PDM Kota Malang membuka kantor cabang baru di wilayah Malang Selatan.',
        type: 'news',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Pengumuman Jadwal Kegiatan',
        body: 'Perubahan jadwal kegiatan rutin mingguan menjadi hari Jumat pukul 19.00 WIB.',
        type: 'announcement',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'Bakti Sosial Peduli Sesama',
        body: 'Mari berpartisipasi dalam kegiatan bakti sosial di wilayah terdampak bencana.',
        type: 'agenda',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'Update Aplikasi PDM Malang',
        body: 'Tersedia fitur baru untuk memudahkan koordinasi dan informasi organisasi.',
        type: 'general',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        title: 'Rapat Koordinasi Pengurus',
        body: 'Harap hadir dalam rapat koordinasi pengurus periode 2024 pada hari Sabtu.',
        type: 'agenda',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        isRead: true,
      ),
    ];
    notifyListeners();
  }

  // Filter notifications
  List<NotificationModel> get filteredNotifications {
    if (_selectedFilter == 'Semua') {
      return _notifications;
    }
    
    String typeFilter = '';
    switch (_selectedFilter) {
      case 'Berita':
        typeFilter = 'news';
        break;
      case 'Agenda':
        typeFilter = 'agenda';
        break;
      case 'Pengumuman':
        typeFilter = 'announcement';
        break;
    }
    
    return _notifications.where((n) => n.type == typeFilter).toList();
  }

  // Set filter
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Add new notification
  void _addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Mark as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  // Delete notification
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Get icon based on type
  IconData getIconForType(String type) {
    switch (type) {
      case 'news':
        return RemixIcons.article_line;
      case 'agenda':
        return RemixIcons.calendar_event_line;
      case 'announcement':
        return RemixIcons.megaphone_line;
      default:
        return RemixIcons.notification_3_line;
    }
  }

  // Get color based on type
  Color getColorForType(String type) {
    switch (type) {
      case 'news':
        return const Color(0xFF2196F3);
      case 'agenda':
        return const Color(0xFF39A658);
      case 'announcement':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF152D8D);
    }
  }

  // Format time ago
  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
