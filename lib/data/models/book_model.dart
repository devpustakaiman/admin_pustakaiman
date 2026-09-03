import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.synopsis,
    required super.coverUrl,
    required super.pdfPreviewUrl,
    required super.mizanstoreUrl,
    required super.category,
    super.galleryUrls = const [],
    super.price = 0,
    super.isPromo = false,
    super.promoPrice,
    super.promoPercentage,
    super.promoEndDate,
    super.isRecommended = false,
    super.updatedAt,
    super.createdAt,
    super.deletedAt,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final rawGallery = json['gallery_urls'] ?? json['galleryUrls'];
    List<String> parsedGallery = const [];
    if (rawGallery is List) {
      parsedGallery = rawGallery.map((e) => e.toString()).toList();
    }

    final rawPrice = json['price'];
    int parsedPrice = 0;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toInt();
    } else if (rawPrice is String) {
      parsedPrice = int.tryParse(rawPrice) ?? 0;
    }

    int? parseOptionalInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return BookModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      synopsis: json['synopsis'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? json['coverUrl'] as String? ?? '',
      pdfPreviewUrl: json['pdf_preview_url'] as String? ?? json['pdfPreviewUrl'] as String? ?? '',
      mizanstoreUrl: json['mizanstore_url'] as String? ?? json['mizanstoreUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      galleryUrls: parsedGallery,
      price: parsedPrice,
      isPromo: json['is_promo'] as bool? ?? json['isPromo'] as bool? ?? false,
      promoPrice: parseOptionalInt(json['promo_price'] ?? json['promoPrice']),
      promoPercentage: parseOptionalInt(json['promo_percentage'] ?? json['promoPercentage']),
      promoEndDate: parseDateTime(json['promo_end_date'] ?? json['promoEndDate']),
      isRecommended: json['is_recommended'] as bool? ?? json['isRecommended'] as bool? ?? false,
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
      deletedAt: parseDateTime(json['deleted_at'] ?? json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'author': author,
      'synopsis': synopsis,
      'category': category,
      'price': price,
      'cover_url': coverUrl,
      'pdf_preview_url': pdfPreviewUrl,
      'mizanstore_url': mizanstoreUrl,
      'gallery_urls': galleryUrls,
      'is_promo': isPromo,
      'promo_price': promoPrice,
      'promo_percentage': promoPercentage,
      'promo_end_date': promoEndDate?.toIso8601String(),
      'is_recommended': isRecommended,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    if (updatedAt != null) {
      map['updated_at'] = updatedAt!.toIso8601String();
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    if (deletedAt != null) {
      map['deleted_at'] = deletedAt!.toIso8601String();
    }
    return map;
  }
}
