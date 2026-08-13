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
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      synopsis: json['synopsis'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      pdfPreviewUrl: json['pdfPreviewUrl'] as String? ?? '',
      mizanstoreUrl: json['mizanstoreUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
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
    };
  }
}
