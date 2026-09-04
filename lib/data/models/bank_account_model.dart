class BankAccountModel {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolder;

  const BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString() ?? '',
      accountHolder: json['account_holder']?.toString() ?? json['accountHolder']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder': accountHolder,
    };
  }

  BankAccountModel copyWith({
    String? id,
    String? bankName,
    String? accountNumber,
    String? accountHolder,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
    );
  }
}
