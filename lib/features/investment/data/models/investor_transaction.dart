import 'package:json_annotation/json_annotation.dart';

part 'investor_transaction.g.dart';

@JsonSerializable()
class InvestorTransaction {
  final String? transId;
  final int? schemeId;
  final int? investorId;
  final DateTime? transDate;
  final String? description;
  final double? amount;
  final double? offerPrice;
  final double? bidPrice;
  final String? transType; // "W" for Withdrawal, "D" for Deposit
  final double? transUnits;
  final double? salesCharge;
  final double? salesPercent;
  final int? userId;
  final int? checkedBy;
  final DateTime? checkedDate;
  final String? checked;
  final DateTime? valueDate;
  final int? repId;
  final String? transStat;
  final String? uploaded;
  final DateTime? uploadedDate;
  final String? certificateNumber;
  final String? flagNaration;
  final String? posted;
  final DateTime? postedDate;
  final int? postUser;
  final String? orderNo;
  final String? transactionRN;
  final String? sessionId;
  final String? sessionUID;

  InvestorTransaction({
    this.transId,
    this.schemeId,
    this.investorId,
    this.transDate,
    this.description,
    this.amount,
    this.offerPrice,
    this.bidPrice,
    this.transType,
    this.transUnits,
    this.salesCharge,
    this.salesPercent,
    this.userId,
    this.checkedBy,
    this.checkedDate,
    this.checked,
    this.valueDate,
    this.repId,
    this.transStat,
    this.uploaded,
    this.uploadedDate,
    this.certificateNumber,
    this.flagNaration,
    this.posted,
    this.postedDate,
    this.postUser,
    this.orderNo,
    this.transactionRN,
    this.sessionId,
    this.sessionUID,
  });

  factory InvestorTransaction.fromJson(Map<String, dynamic> json) =>
      _$InvestorTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$InvestorTransactionToJson(this);

  // Helper method to get transaction type display name with units for buy/sell
  String getTransactionTypeDisplay() {
    final unitsStr = transUnits != null ? transUnits!.toStringAsFixed(0) : '0';

    switch (transType) {
      case 'W':
        return 'Withdrawal';
      case 'D':
        return 'Deposit';
      case 'B':
        return 'Bought $unitsStr units';
      case 'S':
        return 'Sold $unitsStr units';
      default:
        return 'Unknown';
    }
  }

  // Helper method to get brief transaction type for filters
  String getTransactionTypeShort() {
    switch (transType) {
      case 'W':
        return 'Withdrawal';
      case 'D':
        return 'Deposit';
      case 'B':
        return 'Bought';
      case 'S':
        return 'Sold';
      default:
        return 'Unknown';
    }
  }

  String _formatIntegerWithCommas(String value) {
    if (value.isEmpty) return '0';
    final isNegative = value.startsWith('-');
    final digits = isNegative ? value.substring(1) : value;
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      final indexFromRight = digits.length - i;
      buffer.write(digits[i]);
      if (indexFromRight > 1 && indexFromRight % 3 == 1) {
        buffer.write(',');
      }
    }

    return isNegative ? '-$buffer' : buffer.toString();
  }

  // Helper method to format amount with sign
  String getFormattedAmount() {
    if (amount == null) return '₦0.00';
    // W, B = debit (negative), D, S = credit (positive) - but B should be negative
    final sign = (transType == 'W' || transType == 'B') ? '-' : '+';
    final parts = amount!.toStringAsFixed(2).split('.');
    final formattedWhole = _formatIntegerWithCommas(parts[0]);
    return '$sign₦$formattedWhole.${parts[1]}';
  }

  // Helper method to determine if withdrawal
  bool isWithdrawal() => transType == 'W';

  // Helper method to determine if deposit
  bool isDeposit() => transType == 'D';

  // Helper method to determine if buy
  bool isBuy() => transType == 'B';

  // Helper method to determine if sell
  bool isSell() => transType == 'S';

  // Helper method to determine if debit (withdrawal or buy)
  bool isDebit() => transType == 'W' || transType == 'B';

  // Helper method to determine if credit (deposit or sell)
  bool isCredit() => transType == 'D' || transType == 'S';
}
