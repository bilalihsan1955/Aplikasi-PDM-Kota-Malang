/// Model agenda/event sesuai response API.
/// Getter [month], [date], [time] dipakai untuk card list (Agenda & Home).
class AgendaModel {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String image;
  final String eventDate;
  final String eventTime;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? organizer;
  final String? contactPerson;
  final String? contactPhone;
  final String? dressCode;
  final int? maxParticipants;
  final String? registrationLink;
  final String status;
  final EventCategory? category;
  final String? createdAt;
  final String? updatedAt;

  AgendaModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.image,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    this.latitude,
    this.longitude,
    this.organizer,
    this.contactPerson,
    this.contactPhone,
    this.dressCode,
    this.maxParticipants,
    this.registrationLink,
    required this.status,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  static const List<String> _monthNames = [
    'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'
  ];

  /// Untuk card: bulan singkatan (JAN, FEB, ...).
  String get month {
    if (eventDate.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(eventDate);
      if (dt == null) return '';
      return dt.month >= 1 && dt.month <= 12 ? _monthNames[dt.month - 1] : '';
    } catch (_) {
      return '';
    }
  }

  /// Untuk card: tanggal (day of month).
  String get date {
    if (eventDate.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(eventDate);
      if (dt == null) return '';
      return '${dt.day}';
    } catch (_) {
      return '';
    }
  }

  /// Untuk card: waktu tampilan format "09.00 - selesai".
  String get time {
    int? hour;
    int? minute;
    String raw = eventTime.trim();
    if (raw.isNotEmpty) {
      final parts = raw.replaceAll('.', ':').split(':');
      if (parts.length >= 2) {
        hour = int.tryParse(parts[0].trim());
        minute = int.tryParse(parts[1].trim());
      }
      if (hour == null || minute == null) {
        final match = RegExp(r'(\d{1,2})[.:](\d{2})').firstMatch(raw);
        if (match != null) {
          hour = int.tryParse(match.group(1)!);
          minute = int.tryParse(match.group(2)!);
        }
      }
    }
    if ((hour == null || minute == null) && eventDate.isNotEmpty && (eventDate.contains(' ') || eventDate.contains('T'))) {
      final dt = DateTime.tryParse(eventDate);
      if (dt != null) {
        hour = dt.hour;
        minute = dt.minute;
      }
    }
    if (hour != null && minute != null) {
      return _formatTimeRange(hour, minute, null, null);
    }
    if (raw.isNotEmpty) return '$raw - selesai';
    return '';
  }

  /// Format tampilan: "09.00 - selesai" atau "09.00 - 11.00" jika end time ada.
  static String _formatTimeRange(int startH, int startM, int? endH, int? endM) {
    final start = '${startH.toString().padLeft(2, '0')}.${startM.toString().padLeft(2, '0')}';
    if (endH != null && endM != null) {
      final end = '${endH.toString().padLeft(2, '0')}.${endM.toString().padLeft(2, '0')}';
      return '$start - $end';
    }
    return '$start - selesai';
  }

  /// Nama kategori untuk filter chip.
  String get categoryName => category?.name ?? 'Agenda';

  /// DateTime mulai acara (eventDate + eventTime) untuk filter/sort "yang akan datang".
  DateTime? get eventDateTime {
    if (eventDate.isEmpty) return null;
    try {
      final d = DateTime.tryParse(eventDate);
      if (d == null) return null;
      if (eventTime.isEmpty) return DateTime(d.year, d.month, d.day);
      final parts = eventTime.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return DateTime(d.year, d.month, d.day, h, m);
      }
      return DateTime(d.year, d.month, d.day);
    } catch (_) {
      return null;
    }
  }

  /// True jika acara belum lewat (mulai >= sekarang).
  bool get isUpcoming {
    final dt = eventDateTime;
    return dt != null && dt.isAfter(DateTime.now());
  }

  /// Deskripsi untuk tampilan: tag HTML dihilangkan.
  String get displayDescription {
    if (description.isEmpty) return '';
    return description
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Tanggal format lengkap untuk detail (mis. 20 Feb 2025).
  String get eventDateFormatted {
    if (eventDate.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(eventDate);
      if (dt == null) return eventDate;
      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final monthStr = dt.month >= 1 && dt.month <= 12 ? m[dt.month - 1] : '${dt.month}';
      return '${dt.day} $monthStr ${dt.year}';
    } catch (_) {
      return eventDate;
    }
  }

  /// Baca event_time dari raw dan json (langsung + cari key yang mengandung "time").
  static String _readEventTime(Map<String, dynamic> raw, Map<String, dynamic> json) {
    String? t;
    t = raw['event_time']?.toString().trim();
    if (t != null && t.isNotEmpty) return _normalizeTimeStr(t);
    t = raw['eventTime']?.toString().trim();
    if (t != null && t.isNotEmpty) return _normalizeTimeStr(t);
    t = json['event_time']?.toString().trim();
    if (t != null && t.isNotEmpty) return _normalizeTimeStr(t);
    t = json['eventTime']?.toString().trim();
    if (t != null && t.isNotEmpty) return _normalizeTimeStr(t);
    for (final entry in raw.entries) {
      final k = entry.key.toString().toLowerCase();
      if ((k == 'event_time' || k == 'eventtime' || k == 'start_time' || k == 'time') && entry.value != null) {
        t = entry.value.toString().trim();
        if (t.isNotEmpty) return _normalizeTimeStr(t);
      }
    }
    final dateStr = (raw['event_date'] ?? json['event_date'])?.toString().trim() ?? '';
    if (dateStr.contains(' ') || dateStr.contains('T')) {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null && (dt.hour != 0 || dt.minute != 0)) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
      }
    }
    return '';
  }

  /// Normalisasi "09.00", "09:00", "09:00:00" → "09:00:00" untuk parsing di getter time.
  static String _normalizeTimeStr(String s) {
    final parts = s.replaceAll('.', ':').split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0].trim()) ?? 0;
      final m = int.tryParse(parts[1].trim()) ?? 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00';
    }
    return s;
  }

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> raw = (json['event'] is Map)
        ? Map<String, dynamic>.from(json['event'] as Map)
        : (json['data'] is Map && json.length == 1)
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json;

    final String eventTimeValue = _readEventTime(raw, json);

    EventCategory? cat;
    if (raw['category'] is Map) {
      try {
        cat = EventCategory.fromJson(Map<String, dynamic>.from(raw['category'] as Map));
      } catch (_) {}
    }
    return AgendaModel(
      id: (raw['id'] as num?)?.toInt() ?? 0,
      title: (raw['title'] as String?) ?? '',
      slug: (raw['slug'] as String?) ?? '',
      description: (raw['description'] as String?) ?? '',
      image: (raw['image'] as String?) ?? '',
      eventDate: (raw['event_date'] as String?) ?? '',
      eventTime: eventTimeValue,
      location: (raw['location'] as String?) ?? '',
      latitude: (raw['latitude'] as num?)?.toDouble(),
      longitude: (raw['longitude'] as num?)?.toDouble(),
      organizer: raw['organizer'] as String?,
      contactPerson: raw['contact_person'] as String?,
      contactPhone: raw['contact_phone'] as String?,
      dressCode: (raw['dress_code'] ?? raw['dressCode']) as String?,
      maxParticipants: (raw['max_participants'] as num?)?.toInt(),
      registrationLink: raw['registration_link'] as String?,
      status: (raw['status'] as String?) ?? 'upcoming',
      category: cat,
      createdAt: raw['created_at'] as String?,
      updatedAt: raw['updated_at'] as String?,
    );
  }
}

class EventCategory {
  final int id;
  final String name;
  final String slug;

  EventCategory({required this.id, required this.name, required this.slug});

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
    );
  }
}
