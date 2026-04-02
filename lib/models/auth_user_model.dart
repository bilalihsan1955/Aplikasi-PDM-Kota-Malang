class AuthUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? position;
  final String? department;
  final String? nbm;
  final String? avatar;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.position,
    this.department,
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
      department: json['department']?.toString(),
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
      if (department != null) 'department': department,
      if (nbm != null) 'nbm': nbm,
      if (avatar != null) 'avatar': avatar,
    };
  }
}

