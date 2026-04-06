class AccountLookupResponse {
  final String accountNumber;
  final String bankId;
  final String accountName;

  const AccountLookupResponse({
    required this.accountNumber,
    required this.bankId,
    required this.accountName,
  });

  factory AccountLookupResponse.fromJson(Map<String, dynamic> json) {
    return AccountLookupResponse(
      accountNumber:
          (json['account_number'] ?? json['accountNumber'] ?? '').toString(),
      bankId: (json['bank_id'] ?? json['bankId'] ?? '').toString(),
      accountName:
          (json['account_name'] ?? json['accountName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_number': accountNumber,
      'bank_id': bankId,
      'account_name': accountName,
    };
  }
}

