class NotificationModel {
  final int id;
  final int? userId;
  final String title;
  final String body;
  final String topic;
  final String? urlRedirect;
  final String? tipeRedirect;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.topic,
    this.urlRedirect,
    this.tipeRedirect,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    String? topic,
    String? urlRedirect,
    String? tipeRedirect,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      topic: topic ?? this.topic,
      urlRedirect: urlRedirect ?? this.urlRedirect,
      tipeRedirect: tipeRedirect ?? this.tipeRedirect,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static int _parseId(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static int? _parseUserId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  /// Respons API/FCM: objek datar **atau** `{ "notification": {...}, "data": {...} }`.
  static Map<String, dynamic> flattenNotificationJson(Map<String, dynamic> json) {
    final notif = json['notification'];
    final data = json['data'];
    if (notif is Map && data is Map) {
      final nm = Map<String, dynamic>.from(notif);
      final dm = Map<String, dynamic>.from(data);
      final merged = Map<String, dynamic>.from(dm);
      final t = merged['title']?.toString().trim();
      final b = merged['body']?.toString().trim();
      if (t == null || t.isEmpty) {
        merged['title'] = nm['title'];
      }
      if (b == null || b.isEmpty) {
        merged['body'] = nm['body'];
      }
      return merged;
    }
    return Map<String, dynamic>.from(json);
  }

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v?.toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }

  /// Tanggal untuk UI (`formatNotificationMeta` / `formatCreatedAt`) dari API: **`created_at`**.
  /// Hanya `createdAt` dipakai sebagai alias nama field yang sama.
  static DateTime _parseCreatedAtFromFlat(Map<String, dynamic> flat) {
    final raw = flat['created_at'] ?? flat['createdAt'];

    if (raw == null) return DateTime.now();

    if (raw is int) {
      // Backend bisa kirim epoch seconds atau milliseconds.
      final ms = raw < 1000000000000 ? raw * 1000 : raw;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    if (raw is num) {
      final n = raw.toInt();
      final ms = n < 1000000000000 ? n * 1000 : n;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }

    final s = raw.toString().trim();
    if (s.isEmpty) return DateTime.now();
    final asInt = int.tryParse(s);
    if (asInt != null) {
      final ms = asInt < 1000000000000 ? asInt * 1000 : asInt;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  /// Samakan variasi kunci dari FCM/backend ke `tipe_redirect` / `url_redirect`.
  static void applyTipeUrlAliases(Map<String, dynamic> flat) {
    String? firstNonEmpty(Iterable<String> keys) {
      for (final key in keys) {
        final v = flat[key]?.toString().trim();
        if (v != null && v.isNotEmpty) return v;
      }
      return null;
    }

    final tipe = firstNonEmpty(const [
      'tipe_redirect',
      'tipeRedirect',
      'type',
      'tipe',
      'redirect_type',
      'redirectType',
      'notification_type',
      'notificationType',
    ]);
    if (tipe != null) {
      flat['tipe_redirect'] = tipe;
    }

    final url = firstNonEmpty(const [
      'url_redirect',
      'urlRedirect',
      'link',
      'deep_link',
      'deepLink',
    ]);
    if (url != null) {
      flat['url_redirect'] = url;
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final flat = flattenNotificationJson(json);
    applyTipeUrlAliases(flat);
    final topicRaw = flat['topic']?.toString().trim().toLowerCase();
    return NotificationModel(
      id: _parseId(flat['id']),
      userId: _parseUserId(flat['user_id']),
      title: flat['title']?.toString() ?? '',
      body: flat['body']?.toString() ?? '',
      topic: topicRaw == null || topicRaw.isEmpty ? 'all' : topicRaw,
      urlRedirect: flat['url_redirect']?.toString(),
      tipeRedirect: () {
        final t = flat['tipe_redirect']?.toString().trim();
        if (t == null || t.isEmpty) return null;
        return t.toLowerCase();
      }(),
      createdAt: _parseCreatedAtFromFlat(flat),
      isRead: _parseBool(flat['is_read']) || _parseBool(flat['read']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'topic': topic,
      'url_redirect': urlRedirect,
      'tipe_redirect': tipeRedirect,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
