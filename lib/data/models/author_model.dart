import '../../domain/entities/author.dart';

class AuthorModel extends Author {
  const AuthorModel({
    required super.id,
    required super.name,
    required super.bio,
    required super.photoUrl,
    required super.createdAt,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AuthorModel.fromEntity(Author author) {
    return AuthorModel(
      id: author.id,
      name: author.name,
      bio: author.bio,
      photoUrl: author.photoUrl,
      createdAt: author.createdAt,
    );
  }
}
