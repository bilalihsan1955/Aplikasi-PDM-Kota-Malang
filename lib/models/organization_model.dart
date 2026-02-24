/// Profil organisasi — response GET /organization/profile
class OrganizationProfileModel {
  final int id;
  final String name;
  final String shortName;
  final String description;
  final String history;
  final String vision;
  final String mission;
  final String logo;
  final String address;
  final String phone;
  final String email;
  final String website;
  final OrganizationSocialMedia? socialMedia;
  final int? establishedYear;

  OrganizationProfileModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.history,
    required this.vision,
    required this.mission,
    required this.logo,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    this.socialMedia,
    this.establishedYear,
  });

  factory OrganizationProfileModel.fromJson(Map<String, dynamic> json) {
    OrganizationSocialMedia? social;
    if (json['social_media'] is Map) {
      social = OrganizationSocialMedia.fromJson(
        Map<String, dynamic>.from(json['social_media'] as Map),
      );
    }
    return OrganizationProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      shortName: (json['short_name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      history: (json['history'] as String?) ?? '',
      vision: (json['vision'] as String?) ?? '',
      mission: (json['mission'] as String?) ?? '',
      logo: (json['logo'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      website: (json['website'] as String?) ?? '',
      socialMedia: social,
      establishedYear: (json['established_year'] as num?)?.toInt(),
    );
  }
}

class OrganizationSocialMedia {
  final String? facebook;
  final String? instagram;
  final String? youtube;
  final String? twitter;

  OrganizationSocialMedia({
    this.facebook,
    this.instagram,
    this.youtube,
    this.twitter,
  });

  factory OrganizationSocialMedia.fromJson(Map<String, dynamic> json) {
    return OrganizationSocialMedia(
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      youtube: json['youtube'] as String?,
      twitter: json['twitter'] as String?,
    );
  }
}

/// Item struktur organisasi — response GET /organization/structure
class OrganizationStructureModel {
  final int id;
  final String name;
  final String position;
  final String division;
  final String photo;
  final String? phone;
  final String? email;
  final int order;
  final bool isActive;

  OrganizationStructureModel({
    required this.id,
    required this.name,
    required this.position,
    required this.division,
    required this.photo,
    this.phone,
    this.email,
    required this.order,
    required this.isActive,
  });

  factory OrganizationStructureModel.fromJson(Map<String, dynamic> json) {
    return OrganizationStructureModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      position: (json['position'] as String?) ?? '',
      division: (json['division'] as String?) ?? '',
      photo: (json['photo'] as String?) ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }
}
