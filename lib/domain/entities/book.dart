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
  final bool isUpcoming;
  final DateTime? releaseDate;
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
    this.isUpcoming = false,
    this.releaseDate,
    this.updatedAt,
    this.createdAt,
    this.deletedAt,
  });

  /// True if promo is toggled ON and has not expired.
  /// If [promoEndDate] is null, promo is considered permanent ("Forever").
  bool get isPromoActive {
    if (!isPromo) return false;
    if (promoEndDate == null) return true; // Permanent ("Forever")
    final endOfDay = DateTime(
      promoEndDate!.year,
      promoEndDate!.month,
      promoEndDate!.day,
      23,
      59,
      59,
    );
    return endOfDay.isAfter(DateTime.now());
  }

  /// True if promo is toggled ON but the end date has passed.
  bool get isPromoExpired {
    if (!isPromo) return false;
    if (promoEndDate == null) return false;
    final endOfDay = DateTime(
      promoEndDate!.year,
      promoEndDate!.month,
      promoEndDate!.day,
      23,
      59,
      59,
    );
    return endOfDay.isBefore(DateTime.now());
  }

  /// True if promo is toggled ON with no end date limit.
  bool get isPromoPermanent {
    return isPromo && promoEndDate == null;
  }
}
