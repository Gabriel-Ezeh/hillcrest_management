// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investor_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvestorTransaction _$InvestorTransactionFromJson(Map<String, dynamic> json) =>
    InvestorTransaction(
      transId: json['transId'] as String?,
      schemeId: (json['schemeId'] as num?)?.toInt(),
      investorId: (json['investorId'] as num?)?.toInt(),
      transDate: json['transDate'] == null
          ? null
          : DateTime.parse(json['transDate'] as String),
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      bidPrice: (json['bidPrice'] as num?)?.toDouble(),
      transType: json['transType'] as String?,
      transUnits: (json['transUnits'] as num?)?.toDouble(),
      salesCharge: (json['salesCharge'] as num?)?.toDouble(),
      salesPercent: (json['salesPercent'] as num?)?.toDouble(),
      userId: (json['userId'] as num?)?.toInt(),
      checkedBy: (json['checkedBy'] as num?)?.toInt(),
      checkedDate: json['checkedDate'] == null
          ? null
          : DateTime.parse(json['checkedDate'] as String),
      checked: json['checked'] as String?,
      valueDate: json['valueDate'] == null
          ? null
          : DateTime.parse(json['valueDate'] as String),
      repId: (json['repId'] as num?)?.toInt(),
      transStat: json['transStat'] as String?,
      uploaded: json['uploaded'] as String?,
      uploadedDate: json['uploadedDate'] == null
          ? null
          : DateTime.parse(json['uploadedDate'] as String),
      certificateNumber: json['certificateNumber'] as String?,
      flagNaration: json['flagNaration'] as String?,
      posted: json['posted'] as String?,
      postedDate: json['postedDate'] == null
          ? null
          : DateTime.parse(json['postedDate'] as String),
      postUser: (json['postUser'] as num?)?.toInt(),
      orderNo: json['orderNo'] as String?,
      transactionRN: json['transactionRN'] as String?,
      sessionId: json['sessionId'] as String?,
      sessionUID: json['sessionUID'] as String?,
    );

Map<String, dynamic> _$InvestorTransactionToJson(
  InvestorTransaction instance,
) => <String, dynamic>{
  'transId': instance.transId,
  'schemeId': instance.schemeId,
  'investorId': instance.investorId,
  'transDate': instance.transDate?.toIso8601String(),
  'description': instance.description,
  'amount': instance.amount,
  'offerPrice': instance.offerPrice,
  'bidPrice': instance.bidPrice,
  'transType': instance.transType,
  'transUnits': instance.transUnits,
  'salesCharge': instance.salesCharge,
  'salesPercent': instance.salesPercent,
  'userId': instance.userId,
  'checkedBy': instance.checkedBy,
  'checkedDate': instance.checkedDate?.toIso8601String(),
  'checked': instance.checked,
  'valueDate': instance.valueDate?.toIso8601String(),
  'repId': instance.repId,
  'transStat': instance.transStat,
  'uploaded': instance.uploaded,
  'uploadedDate': instance.uploadedDate?.toIso8601String(),
  'certificateNumber': instance.certificateNumber,
  'flagNaration': instance.flagNaration,
  'posted': instance.posted,
  'postedDate': instance.postedDate?.toIso8601String(),
  'postUser': instance.postUser,
  'orderNo': instance.orderNo,
  'transactionRN': instance.transactionRN,
  'sessionId': instance.sessionId,
  'sessionUID': instance.sessionUID,
};
