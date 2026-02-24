/// Model item galeri sesuai response API.
/// Response: { "data": [ { "id", "title", "description", "image", "type", "created_at" } ] }
class GalleryModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final String type;
  final String? createdAt;

  GalleryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.type,
    this.createdAt,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'photo',
      createdAt: json['created_at'] as String?,
    );
  }
}
