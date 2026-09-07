import '../../domain/entities/submission.dart';

class SubmissionModel extends Submission {
  const SubmissionModel({
    required super.id,
    required super.senderName,
    required super.email,
    super.phone = '',
    super.title = '',
    required super.synopsis,
    required super.pdfDocumentUrl,
    super.paymentProofUrl = '',
    required super.status,
    required super.createdAt,
    super.deletedAt,
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

    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final parsedPhone = json['phone']?.toString() ??
        json['whatsapp']?.toString() ??
        json['no_wa']?.toString() ??
        json['phone_number']?.toString() ??
        json['whatsapp_number']?.toString() ??
        json['no_telepon']?.toString() ??
        '';

    final parsedTitle = json['title']?.toString() ??
        json['book_title']?.toString() ??
        json['judul_naskah']?.toString() ??
        json['naskah_title']?.toString() ??
        json['judul']?.toString() ??
        '';

    final parsedPaymentProof = json['payment_proof_url']?.toString() ??
        json['paymentProofUrl']?.toString() ??
        json['bukti_transfer_url']?.toString() ??
        json['bukti_transfer']?.toString() ??
        json['proof_url']?.toString() ??
        json['bukti_bayar']?.toString() ??
        '';

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
      phone: parsedPhone,
      title: parsedTitle,
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
      paymentProofUrl: parsedPaymentProof,
      status: json['status']?.toString() ?? 'pending',
      createdAt: parsedCreatedAt,
      deletedAt: parseDateTime(json['deleted_at'] ?? json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'sender_name': senderName,
      'email': email,
      'phone': phone,
      'title': title,
      'synopsis': synopsis,
      'pdf_document_url': pdfDocumentUrl,
      'payment_proof_url': paymentProofUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
    if (deletedAt != null) {
      map['deleted_at'] = deletedAt!.toIso8601String();
    }
    return map;
  }
}
