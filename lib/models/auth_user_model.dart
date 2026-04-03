class AuthUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? position;
  final String? nbm;
  final String? avatar;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.position,
    this.nbm,
    this.avatar,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phone: json['phone']?.toString(),
      position: json['position']?.toString(),
      nbm: json['nbm']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (phone != null) 'phone': phone,
      if (position != null) 'position': position,
      if (nbm != null) 'nbm': nbm,
      if (avatar != null) 'avatar': avatar,
    };
  }

  static String? _nonEmpty(String? s) {
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  /// Untuk menghindari flicker: UI tidak perlu di-rebuild jika data tampilan sama.
  bool sameDisplayData(AuthUser other) {
    return id == other.id &&
        name == other.name &&
        email == other.email &&
        role == other.role &&
        (phone ?? '') == (other.phone ?? '') &&
        (position ?? '') == (other.position ?? '') &&
        (nbm ?? '') == (other.nbm ?? '') &&
        (avatar ?? '') == (other.avatar ?? '');
  }

  /// Gabungkan respons server dengan cache: isi dari API dipakai jika ada; sisanya dari [previous].
  AuthUser mergedWithServer(AuthUser previous) {
    return AuthUser(
      id: id,
      name: _nonEmpty(name) ?? previous.name,
      email: _nonEmpty(email) ?? previous.email,
      role: _nonEmpty(role) ?? previous.role,
      phone: _nonEmpty(phone) ?? previous.phone,
      position: _nonEmpty(position) ?? previous.position,
      nbm: _nonEmpty(nbm) ?? previous.nbm,
      avatar: _nonEmpty(avatar) ?? previous.avatar,
    );
  }
}
