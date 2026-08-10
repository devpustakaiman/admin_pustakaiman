class Submission {
  final String id;
  final String senderName;
  final String email;
  final String synopsis;
  final String pdfDocumentUrl;
  final String status;
  final DateTime createdAt;

  const Submission({
    required this.id,
    required this.senderName,
    required this.email,
    required this.synopsis,
    required this.pdfDocumentUrl,
    required this.status,
    required this.createdAt,
  });
}
