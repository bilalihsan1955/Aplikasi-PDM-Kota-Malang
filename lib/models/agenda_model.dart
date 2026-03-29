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

  /// Untuk card (Home & Agenda List): format "09.00 - Selesai".
  String get time {
    final raw = eventTime.trim();
    if (raw.isEmpty) {
      if (eventDate.contains('T') || eventDate.contains(' ')) {
        final dt = DateTime.tryParse(eventDate);
        if (dt != null && (dt.hour != 0 || dt.minute != 0)) {
          return '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')} - Selesai';
        }
      }
      return '';
    }
    final match = RegExp(r'(\d{1,2})[.:](\d{2})').firstMatch(raw);
    if (match != null) {
      final h = match.group(1)!.padLeft(2, '0');
      final m = match.group(2)!.padLeft(2, '0');
      return '$h.$m - Selesai';
    }
    return '$raw - Selesai';
  }

  /// Untuk halaman detail: waktu murni sesuai respons API (misal 15:30 - 18:00 WIB).
  String get timeDetail {
    final raw = eventTime.trim();
    return raw.isNotEmpty ? raw : time;
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
      final match = RegExp(r'(\d{1,2})[.:](\d{2})').firstMatch(eventTime);
      if (match != null) {
        final h = int.tryParse(match.group(1)!) ?? 0;
        final m = int.tryParse(match.group(2)!) ?? 0;
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
    if (t != null && t.isNotEmpty) return t;
    t = raw['eventTime']?.toString().trim();
    if (t != null && t.isNotEmpty) return t;
    t = json['event_time']?.toString().trim();
    if (t != null && t.isNotEmpty) return t;
    t = json['eventTime']?.toString().trim();
    if (t != null && t.isNotEmpty) return t;
    for (final entry in raw.entries) {
      final k = entry.key.toString().toLowerCase();
      if ((k == 'event_time' || k == 'eventtime' || k == 'start_time' || k == 'time') && entry.value != null) {
        t = entry.value.toString().trim();
        if (t.isNotEmpty) return t;
      }
    }
    final dateStr = (raw['event_date'] ?? json['event_date'])?.toString().trim() ?? '';
    if (dateStr.contains(' ') || dateStr.contains('T')) {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null && (dt.hour != 0 || dt.minute != 0)) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }
    return '';
  }

  /// Baca nilai double dari raw, coba key utama dulu lalu key alternatif (mis. latitude lalu lat).
  static double? _readDouble(Map<String, dynamic> raw, String primaryKey, String alternateKey) {
    final v = raw[primaryKey];
    if (v != null && v is num) return v.toDouble();
    final alt = raw[alternateKey];
    if (alt != null && alt is num) return alt.toDouble();
    return null;
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
      latitude: _readDouble(raw, 'latitude', 'lat'),
      longitude: _readDouble(raw, 'longitude', 'long'),
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
