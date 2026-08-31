class Book {
  final String id;
  final String title;
  final String author;
  final String synopsis;
  final String coverUrl;
  final String pdfPreviewUrl;
  final String mizanstoreUrl;
  final String category;
  final List<String> galleryUrls;
  final int price;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.synopsis,
    required this.coverUrl,
    required this.pdfPreviewUrl,
    required this.mizanstoreUrl,
    required this.category,
    this.galleryUrls = const [],
    this.price = 0,
  });
}
