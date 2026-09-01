class Author {
  final String id;
  final String name;
  final String bio;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const Author({
    required this.id,
    required this.name,
    required this.bio,
    required this.photoUrl,
    required this.createdAt,
    this.deletedAt,
  });
}
