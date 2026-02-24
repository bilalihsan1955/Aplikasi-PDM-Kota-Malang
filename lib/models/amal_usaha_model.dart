/// Model item amal usaha sesuai response API.
/// GET /amal-usaha → { "data": [ { "id", "name", "slug", "type", "type_label", "description", "image", "logo", "address", "phone", "email", "website", "head_name", "established_year", "is_active", "created_at" } ] }
class AmalUsahaItem {
  final int id;
  final String name;
  final String slug;
  final String type;
  final String typeLabel;
  final String description;
  final String image;
  final String logo;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String headName;
  final int? establishedYear;
  final bool isActive;
  final String? createdAt;

  AmalUsahaItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.typeLabel,
    required this.description,
    required this.image,
    required this.logo,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.headName,
    this.establishedYear,
    required this.isActive,
    this.createdAt,
  });

  /// Untuk kompatibilitas dengan UI yang pakai .title
  String get title => name;

  factory AmalUsahaItem.fromJson(Map<String, dynamic> json) {
    return AmalUsahaItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      typeLabel: (json['type_label'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      logo: (json['logo'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      website: (json['website'] as String?) ?? '',
      headName: (json['head_name'] as String?) ?? '',
      establishedYear: (json['established_year'] as num?)?.toInt(),
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] as String?,
    );
  }
}
