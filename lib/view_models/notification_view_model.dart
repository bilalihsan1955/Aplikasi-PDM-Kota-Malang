import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../models/notification_model.dart';
import '../services/auth/auth_local_service.dart';
import '../services/notification_api_service.dart';
import '../services/notification_read_prefs.dart';
import '../services/notification_deleted_prefs.dart';

class NotificationViewModel extends ChangeNotifier {
  final AuthLocalService _authLocal = AuthLocalService();

  List<NotificationModel> _notifications = [];
  String _selectedFilter = '';
  bool _loading = false;
  String? _error;
  bool _hasFetched = false;

  List<NotificationModel> get notifications => _notifications;

  /// Kunci filter: `''` = Semua, selain itu = nilai `tipe_redirect` (lowercase).
  String get selectedTipeFilter => _selectedFilter;
  bool get loading => _loading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Saat push FCM tiba (biasanya sebelum GET /notifikasi menyertakan baris yang sama).
  /// Sisipkan satu item unread agar badge langsung muncul; [refresh] berikutnya mengganti dari server.
  Future<void> applyIncomingFromPush(NotificationModel incoming) async {
    final fp = NotificationDeletedPrefs.fingerprint(incoming.title, incoming.body);
    final deletedFp = await NotificationDeletedPrefs.getDeletedFingerprints();
    if (deletedFp.contains(fp)) return;
    final deletedIds = await NotificationDeletedPrefs.getDeletedIds();
    if (incoming.id > 0 && deletedIds.contains(incoming.id)) return;

    if (incoming.id != 0 && _notifications.any((n) => n.id == incoming.id)) {
      return;
    }
    final toInsert = incoming.id == 0
        ? incoming.copyWith(
            id: -DateTime.now().microsecondsSinceEpoch,
            isRead: false,
          )
        : incoming.copyWith(isRead: false);
    _notifications = [toInsert, ..._notifications];
    _hasFetched = true;
    notifyListeners();
  }

  /// Urutan tipe yang dikenal (`internal` tidak punya chip — hanya muncul di Semua).
  static const List<String> _knownTipeOrder = [
    'news',
    'event',
    'web',
    'letter',
  ];

  static bool _isInternalTipe(String? t) => t != null && t.toLowerCase().trim() == 'internal';

  /// Chip: Semua, lalu tipe yang ada di data (tanpa `internal`).
  List<String> get filterTipeKeys {
    final present = <String>{};
    for (final n in _notifications) {
      final t = n.tipeRedirect?.toLowerCase().trim();
      if (t != null && t.isNotEmpty && !_isInternalTipe(t)) present.add(t);
    }
    final ordered = _knownTipeOrder.where(present.contains).toList();
    final unknown = present.difference(ordered.toSet()).toList()..sort();
    return ['', ...ordered, ...unknown];
  }

  List<NotificationModel> get filteredNotifications {
    if (_selectedFilter.isEmpty) return _notifications;
    return _notifications
        .where((n) => n.tipeRedirect?.toLowerCase().trim() == _selectedFilter)
        .toList();
  }

  void setFilter(String tipeKey) {
    _selectedFilter = tipeKey;
    notifyListeners();
  }

  /// Label chip untuk kunci tipe (`''` → Semua).
  String filterChipLabel(String tipeKey) {
    if (tipeKey.isEmpty) return 'Semua';
    return tipeDisplayLabel(tipeKey);
  }

  /// Label UI untuk `tipe_redirect`. `internal` → string kosong (tidak ditampilkan).
  String tipeDisplayLabel(String? tipe) {
    final t = tipe?.toLowerCase().trim();
    if (t == null || t.isEmpty) return 'Lainnya';
    switch (t) {
      case 'news':
        return 'Berita';
      case 'event':
        return 'Agenda';
      case 'internal':
        return '';
      case 'web':
        return 'Web';
      case 'letter':
        return 'Surat';
      default:
        if (t.length == 1) return t.toUpperCase();
        return '${t[0].toUpperCase()}${t.substring(1)}';
    }
  }

  IconData getIconForTipe(String? tipe) {
    switch (tipe?.toLowerCase().trim()) {
      case 'news':
        return RemixIcons.article_line;
      case 'event':
        return RemixIcons.calendar_event_line;
      case 'web':
      case 'letter':
        return RemixIcons.global_line;
      case 'internal':
        return RemixIcons.notification_3_line;
      default:
        return RemixIcons.notification_3_line;
    }
  }

  Color getColorForTipe(String? tipe) {
    switch (tipe?.toLowerCase().trim()) {
      case 'news':
        return const Color(0xFF2196F3);
      case 'event':
        return const Color(0xFF39A658);
      case 'web':
        return const Color(0xFF7E57C2);
      case 'letter':
        return const Color(0xFFFF9800);
      case 'internal':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF607D8B);
    }
  }

  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (_loading) return;
    if (_hasFetched && !forceRefresh) return;

    _loading = true;
    _error = null;
    notifyListeners();

    final token = await _authLocal.getToken();
    if (token == null || token.trim().isEmpty) {
      _loading = false;
      _error = 'Silakan login terlebih dahulu';
      notifyListeners();
      return;
    }

    final user = await _authLocal.getCachedUser();
    if (user == null) {
      _loading = false;
      _error = 'Data user tidak ditemukan';
      notifyListeners();
      return;
    }

    final result = await NotificationApiService.fetchNotifications(
      token: token,
      userId: user.id,
    );

    _loading = false;
    _hasFetched = true;

    if (result.success && result.data != null) {
      final readIds = await NotificationReadPrefs.getReadIds();
      final deletedIds = await NotificationDeletedPrefs.getDeletedIds();
      final deletedFp = await NotificationDeletedPrefs.getDeletedFingerprints();

      final incoming = result.data!.map((n) {
        final read = readIds.contains(n.id) || n.isRead;
        return n.copyWith(isRead: read);
      }).where((n) {
        if (deletedIds.contains(n.id)) return false;
        return !deletedFp
            .contains(NotificationDeletedPrefs.fingerprint(n.title, n.body));
      }).toList();

      // Placeholder id<0 dari [applyIncomingFromPush]: pertahankan sampai API punya baris sama (judul+isi).
      final ghosts = _notifications.where((n) => n.id < 0).toList();
      final keptGhosts = ghosts.where((g) {
        if (deletedFp.contains(NotificationDeletedPrefs.fingerprint(g.title, g.body))) {
          return false;
        }
        return !incoming.any((i) => i.title == g.title && i.body == g.body);
      }).toList();

      _notifications = [...keptGhosts, ...incoming];
      _error = null;
    } else {
      _error = result.message ?? 'Gagal memuat notifikasi';
    }

    final available = <String>{''};
    for (final n in _notifications) {
      final t = n.tipeRedirect?.toLowerCase().trim();
      if (t != null && t.isNotEmpty && !_isInternalTipe(t)) available.add(t);
    }
    if (_selectedFilter.isNotEmpty && !available.contains(_selectedFilter)) {
      _selectedFilter = '';
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    _hasFetched = false;
    await loadNotifications(forceRefresh: true);
  }

  Future<void> markAsRead(int id) async {
    await NotificationReadPrefs.addReadId(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final unreadIds = _notifications.where((n) => !n.isRead).map((n) => n.id);
    await NotificationReadPrefs.addReadIds(unreadIds);
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  /// Setelah logout: hapus daftar, flag fetch, dan cache ID baca lokal.
  Future<void> resetForLogout() async {
    await NotificationReadPrefs.clear();
    await NotificationDeletedPrefs.clear();
    _notifications = [];
    _hasFetched = false;
    _error = null;
    _selectedFilter = '';
    notifyListeners();
  }

  Future<void> deleteNotification(NotificationModel n) async {
    _notifications.removeWhere((x) => x.id == n.id);
    await NotificationDeletedPrefs.recordDeletion(
      id: n.id,
      title: n.title,
      body: n.body,
    );
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Tanggal/jam singkat untuk kartu (tanpa paket intl).
  String formatCreatedAt(DateTime d) {
    const m = <int, String>{
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'Mei',
      6: 'Jun',
      7: 'Jul',
      8: 'Agu',
      9: 'Sep',
      10: 'Okt',
      11: 'Nov',
      12: 'Des',
    };
    final mm = m[d.month] ?? '${d.month}';
    final h = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day} $mm ${d.year}, $h.$min';
  }

  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
