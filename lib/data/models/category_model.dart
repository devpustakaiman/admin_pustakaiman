import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.parentId,
    super.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      parentId: json['parent_id'] as String? ?? json['parentId'] as String?,
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'slug': slug,
    };
    if (parentId != null && parentId!.isNotEmpty) {
      map['parent_id'] = parentId;
    }
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    return map;
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      parentId: category.parentId,
      createdAt: category.createdAt,
    );
  }
}
