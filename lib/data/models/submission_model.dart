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
    final createdAtRaw = json['created_at'] ?? json['createdAt'];
    DateTime parsedCreatedAt;
    if (createdAtRaw is String) {
      parsedCreatedAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else if (createdAtRaw is DateTime) {
      parsedCreatedAt = createdAtRaw;
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return SubmissionModel(
      id: json['id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? json['senderName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      synopsis: json['synopsis'] as String? ?? '',
      pdfDocumentUrl: json['pdf_document_url'] as String? ?? json['pdfDocumentUrl'] as String? ?? '',
      status: json['status'] as String? ?? '',
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
