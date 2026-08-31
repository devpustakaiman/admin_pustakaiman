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

    return BookModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      synopsis: json['synopsis'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? json['cover_url'] as String? ?? '',
      pdfPreviewUrl: json['pdfPreviewUrl'] as String? ?? json['pdf_preview_url'] as String? ?? '',
      mizanstoreUrl: json['mizanstoreUrl'] as String? ?? json['mizanstore_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
      galleryUrls: parsedGallery,
      price: parsedPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'synopsis': synopsis,
      'coverUrl': coverUrl,
      'pdfPreviewUrl': pdfPreviewUrl,
      'mizanstoreUrl': mizanstoreUrl,
      'category': category,
      'gallery_urls': galleryUrls,
      'price': price,
    };
  }
}
