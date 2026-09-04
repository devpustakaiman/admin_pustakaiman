class PreorderModel {
  final String id;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String customerName;
  final String email;
  final String phone;
  final String bookTitle;
  final int quantity;
  final String paymentProofUrl;
  final String status;

  PreorderModel({
    required this.id,
    required this.createdAt,
    this.deletedAt,
    required this.customerName,
    required this.email,
    required this.phone,
    required this.bookTitle,
    required this.quantity,
    required this.paymentProofUrl,
    required this.status,
  });

  factory PreorderModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final rawDate = json['created_at'] ?? json['createdAt'] ?? json['date'];
    if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    DateTime? parsedDeletedAt;
    final rawDeletedAt = json['deleted_at'] ?? json['deletedAt'];
    if (rawDeletedAt != null && rawDeletedAt.toString().trim().isNotEmpty) {
      parsedDeletedAt = DateTime.tryParse(rawDeletedAt.toString());
    }

    int parsedQty = 1;
    final rawQty = json['quantity'] ?? json['kuantiti'] ?? json['qty'] ?? json['amount'];
    if (rawQty is num) {
      parsedQty = rawQty.toInt();
    } else if (rawQty is String) {
      parsedQty = int.tryParse(rawQty) ?? 1;
    }

    final rawEmail = json['customer_email'] ?? json['email'] ?? json['user_email'];
    final rawPhone = json['customer_phone'] ?? json['phone'] ?? json['no_hp'] ?? json['whatsapp'] ?? json['phone_number'];
    final rawReceipt = json['transfer_receipt'] ??
        json['receipt_url'] ??
        json['payment_proof_url'] ??
        json['bukti_transfer'] ??
        json['payment_proof'] ??
        json['proof_url'];

    return PreorderModel(
      id: json['id']?.toString() ?? '',
      createdAt: parsedDate,
      deletedAt: parsedDeletedAt,
      customerName: json['customer_name'] ??
          json['nama_pemesan'] ??
          json['name'] ??
          json['sender_name'] ??
          'Pemesan',
      email: (rawEmail != null && rawEmail.toString().trim().isNotEmpty)
          ? rawEmail.toString().trim()
          : '-',
      phone: (rawPhone != null) ? rawPhone.toString().trim() : '',
      bookTitle: json['book_title'] ?? json['judul_buku'] ?? json['book_name'] ?? 'Buku Pre-Order',
      quantity: parsedQty,
      paymentProofUrl: (rawReceipt != null) ? rawReceipt.toString().trim() : '',
      status: json['status']?.toString().toLowerCase() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      'customer_name': customerName,
      'customer_email': email,
      'customer_phone': phone,
      'book_title': bookTitle,
      'quantity': quantity,
      'transfer_receipt': paymentProofUrl,
      'status': status,
    };
  }

  PreorderModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? customerName,
    String? email,
    String? phone,
    String? bookTitle,
    int? quantity,
    String? paymentProofUrl,
    String? status,
  }) {
    return PreorderModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bookTitle: bookTitle ?? this.bookTitle,
      quantity: quantity ?? this.quantity,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      status: status ?? this.status,
    );
  }
}
