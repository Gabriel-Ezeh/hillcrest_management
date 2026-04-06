class CustomerDetailsV4Response {
  final String customerNo;
  final String bankers;
  final String bankCode;
  final String bankAccountNo;
  final String? bankAccountName;

  const CustomerDetailsV4Response({
    required this.customerNo,
    required this.bankers,
    required this.bankCode,
    required this.bankAccountNo,
    this.bankAccountName,
  });

  factory CustomerDetailsV4Response.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsV4Response(
      customerNo: (json['customerNo'] ?? '').toString(),
      bankers: (json['bankers'] ?? '').toString(),
      bankCode: (json['bankCode'] ?? '').toString(),
      bankAccountNo: (json['bankAccountNo'] ?? '').toString(),
      bankAccountName: json['bankAccountName']?.toString(),
    );
  }
}

