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
  final bool isPromo;
  final int? promoPrice;
  final int? promoPercentage;
  final DateTime? promoEndDate;
  final bool isRecommended;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? deletedAt;

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
    this.isPromo = false,
    this.promoPrice,
    this.promoPercentage,
    this.promoEndDate,
    this.isRecommended = false,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });
}
