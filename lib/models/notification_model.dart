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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final flat = flattenNotificationJson(json);
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
      createdAt: flat['created_at'] != null
          ? DateTime.tryParse(flat['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
