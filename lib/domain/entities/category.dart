class Category {
  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final DateTime? createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.createdAt,
  });
}
