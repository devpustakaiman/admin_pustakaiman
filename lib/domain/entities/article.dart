class Article {
  final String id;
  final String title;
  final String slug;
  final String content;
  final DateTime date;
  final String author;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const Article({
    required this.id,
    required this.title,
    this.slug = '',
    required this.content,
    required this.date,
    required this.author,
    required this.imageUrl,
    required this.createdAt,
    this.deletedAt,
  });
}

