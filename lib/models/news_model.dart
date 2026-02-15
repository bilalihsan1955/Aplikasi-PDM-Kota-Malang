/// Model berita sesuai response API.
/// Getter [tag], [time], [desc] dipakai UI agar kompatibel dengan card list.
class NewsModel {
  final int id;
  final String title;
  final String slug;
  final String excerpt;
  final String content;
  final String image;
  final String status;
  final int views;
  final bool isFeatured;
  final String? publishedAt;
  final NewsCategory? category;
  final NewsAuthor? author;
  final String? createdAt;
  final String? updatedAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.image,
    required this.status,
    required this.views,
    required this.isFeatured,
    this.publishedAt,
    this.category,
    this.author,
    this.createdAt,
    this.updatedAt,
  });

  /// Untuk tampilan card: kategori (tag).
  String get tag => category?.name ?? 'Berita';

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  /// Untuk tampilan card: waktu relatif (X jam/hari lalu) atau tanggal dengan nama bulan (mis. 4 Feb 2025).
  String get time {
    if (publishedAt == null || publishedAt!.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(publishedAt!);
      if (dt == null) return publishedAt!;
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      final m = dt.month >= 1 && dt.month <= 12 ? _monthNames[dt.month - 1] : '${dt.month}';
      return '${dt.day} $m ${dt.year}';
    } catch (_) {
      return publishedAt!;
    }
  }

  /// Untuk tampilan card: ringkasan (excerpt).
  String get desc => excerpt;

  /// Tanggal terbit format lengkap untuk halaman detail (contoh: "4 Feb 2025 • 10:00").
  String get publishedAtFormatted {
    if (publishedAt == null || publishedAt!.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(publishedAt!);
      if (dt == null) return publishedAt!;
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final m = dt.month >= 1 && dt.month <= 12 ? months[dt.month - 1] : '${dt.month}';
      return '${dt.day} $m ${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return publishedAt!;
    }
  }

  /// Konten untuk ditampilkan: content jika ada, else excerpt. HTML tag di-strip.
  String get displayContent {
    final raw = content.trim().isEmpty ? excerpt : content;
    return _stripHtml(raw);
  }

  static String _stripHtml(String html) {
    if (html.isEmpty) return html;
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Untuk data dummy (mis. di Home): buat model dari field tampilan card saja.
  factory NewsModel.fromCard({
    required String tag,
    required String time,
    required String title,
    required String desc,
    required String image,
  }) {
    return NewsModel(
      id: 0,
      title: title,
      slug: '',
      excerpt: desc,
      content: '',
      image: image,
      status: 'published',
      views: 0,
      isFeatured: false,
      publishedAt: null,
      category: tag.isNotEmpty ? NewsCategory(id: 0, name: tag, slug: tag.toLowerCase()) : null,
      author: null,
      createdAt: null,
      updatedAt: null,
    );
  }

  static String _s(Map<String, dynamic> j, String key) =>
      (j[key] is String) ? j[key] as String : '';
  static String? _sOpt(Map<String, dynamic> j, String snake, [String? camel]) {
    final v = j[snake] ?? (camel != null ? j[camel] : null);
    return (v is String) ? v : null;
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = _s(json, 'image');
    if (imageUrl.isEmpty) imageUrl = _s(json, 'image_url');
    if (imageUrl.isEmpty) imageUrl = _s(json, 'featured_image');
    NewsCategory? cat;
    if (json['category'] is Map) {
      try {
        cat = NewsCategory.fromJson(Map<String, dynamic>.from(json['category'] as Map));
      } catch (_) {}
    }
    NewsAuthor? auth;
    if (json['author'] is Map) {
      try {
        auth = NewsAuthor.fromJson(Map<String, dynamic>.from(json['author'] as Map));
      } catch (_) {}
    }
    return NewsModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: _s(json, 'title'),
      slug: _s(json, 'slug'),
      excerpt: _s(json, 'excerpt'),
      content: _s(json, 'content'),
      image: imageUrl,
      status: _s(json, 'status').isEmpty ? 'published' : _s(json, 'status'),
      views: (json['views'] as num?)?.toInt() ?? 0,
      isFeatured: (json['is_featured'] as bool?) ?? (json['isFeatured'] as bool?) ?? false,
      publishedAt: _sOpt(json, 'published_at', 'publishedAt'),
      category: cat,
      author: auth,
      createdAt: _sOpt(json, 'created_at', 'createdAt'),
      updatedAt: _sOpt(json, 'updated_at', 'updatedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'image': image,
      'status': status,
      'views': views,
      'is_featured': isFeatured,
      'published_at': publishedAt,
      'category': category?.toJson(),
      'author': author?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class NewsCategory {
  final int id;
  final String name;
  final String slug;

  NewsCategory({required this.id, required this.name, required this.slug});

  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'slug': slug};
}

class NewsAuthor {
  final int id;
  final String name;

  NewsAuthor({required this.id, required this.name});

  factory NewsAuthor.fromJson(Map<String, dynamic> json) {
    return NewsAuthor(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
