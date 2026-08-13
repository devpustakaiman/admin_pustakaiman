class Article {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String author;
  final String imageUrl;
  final DateTime createdAt;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.author,
    required this.imageUrl,
    required this.createdAt,
  });
}
