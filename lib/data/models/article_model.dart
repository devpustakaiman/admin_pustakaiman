import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.content,
    required super.date,
    required super.author,
    required super.imageUrl,
    required super.createdAt,
    super.deletedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return ArticleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      date: parseDateTime(json['date']) ?? DateTime.now(),
      author: json['author'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      deletedAt: parseDateTime(json['deleted_at'] ?? json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'author': author,
      'imageUrl': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
    if (deletedAt != null) {
      map['deleted_at'] = deletedAt!.toIso8601String();
    }
    return map;
  }

  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      id: article.id,
      title: article.title,
      content: article.content,
      date: article.date,
      author: article.author,
      imageUrl: article.imageUrl,
      createdAt: article.createdAt,
      deletedAt: article.deletedAt,
    );
  }
}
