import '../../domain/entities/submission.dart';

class SubmissionModel extends Submission {
  const SubmissionModel({
    required super.id,
    required super.senderName,
    required super.email,
    required super.synopsis,
    required super.pdfDocumentUrl,
    required super.status,
    required super.createdAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'] ?? json['createdAt'] ?? json['date'];
    DateTime parsedCreatedAt;
    if (createdAtRaw is String) {
      parsedCreatedAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else if (createdAtRaw is DateTime) {
      parsedCreatedAt = createdAtRaw;
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return SubmissionModel(
      id: json['id']?.toString() ?? '',
      senderName: json['sender_name']?.toString() ??
          json['senderName']?.toString() ??
          json['name']?.toString() ??
          json['author_name']?.toString() ??
          json['nama_penulis']?.toString() ??
          'Anonim',
      email: json['email']?.toString() ??
          json['email_address']?.toString() ??
          '-',
      synopsis: json['synopsis']?.toString() ??
          json['description']?.toString() ??
          json['sinopsis']?.toString() ??
          '',
      pdfDocumentUrl: json['pdf_document_url']?.toString() ??
          json['pdfDocumentUrl']?.toString() ??
          json['pdf_url']?.toString() ??
          json['file_url']?.toString() ??
          json['document_url']?.toString() ??
          json['url_pdf']?.toString() ??
          '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_name': senderName,
      'email': email,
      'synopsis': synopsis,
      'pdf_document_url': pdfDocumentUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
