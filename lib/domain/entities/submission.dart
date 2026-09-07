class Submission {
  final String id;
  final String senderName;
  final String email;
  final String phone;
  final String title;
  final String synopsis;
  final String pdfDocumentUrl;
  final String paymentProofUrl;
  final String status;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const Submission({
    required this.id,
    required this.senderName,
    required this.email,
    this.phone = '',
    this.title = '',
    required this.synopsis,
    required this.pdfDocumentUrl,
    this.paymentProofUrl = '',
    required this.status,
    required this.createdAt,
    this.deletedAt,
  });
}

