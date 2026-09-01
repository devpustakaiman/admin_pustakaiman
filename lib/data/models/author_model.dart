import '../../domain/entities/author.dart';

class AuthorModel extends Author {
  const AuthorModel({
    required super.id,
    required super.name,
    required super.bio,
    required super.photoUrl,
    required super.createdAt,
    super.deletedAt,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return AuthorModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String? ?? '',
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      deletedAt: parseDateTime(json['deleted_at'] ?? json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
    if (deletedAt != null) {
      map['deleted_at'] = deletedAt!.toIso8601String();
    }
    return map;
  }

  factory AuthorModel.fromEntity(Author author) {
    return AuthorModel(
      id: author.id,
      name: author.name,
      bio: author.bio,
      photoUrl: author.photoUrl,
      createdAt: author.createdAt,
      deletedAt: author.deletedAt,
    );
  }
}
