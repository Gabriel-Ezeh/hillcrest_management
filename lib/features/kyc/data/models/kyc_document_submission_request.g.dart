// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_document_submission_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KycDocument _$KycDocumentFromJson(Map<String, dynamic> json) => KycDocument(
  documentType: json['documentType'] as String,
  documentReference: json['documentReference'] as String,
  documentImage: _uint8ListFromJson(json['documentImage'] as String),
  documentComments: json['documentComments'] as String? ?? '',
  documentConfirmed: json['documentConfirmed'] as bool? ?? false,
  documentValid: json['documentValid'] as bool? ?? false,
  documentIssueDate: json['documentIssueDate'] as String?,
  documentExpiryDate: json['documentExpiryDate'] as String?,
  documentConfirmedBy: json['documentConfirmedBy'] as String?,
  documentConfirmedDate: json['documentConfirmedDate'] as String?,
);

Map<String, dynamic> _$KycDocumentToJson(KycDocument instance) =>
    <String, dynamic>{
      'documentType': instance.documentType,
      'documentReference': instance.documentReference,
      'documentImage': _uint8ListToJson(instance.documentImage),
      'documentComments': instance.documentComments,
      'documentConfirmed': instance.documentConfirmed,
      'documentValid': instance.documentValid,
      'documentIssueDate': instance.documentIssueDate,
      'documentExpiryDate': instance.documentExpiryDate,
      'documentConfirmedBy': instance.documentConfirmedBy,
      'documentConfirmedDate': instance.documentConfirmedDate,
    };

KycJsonBody _$KycJsonBodyFromJson(Map<String, dynamic> json) => KycJsonBody(
  customerno: json['customerno'] as String,
  documents: (json['documents'] as List<dynamic>)
      .map((e) => KycDocument.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$KycJsonBodyToJson(KycJsonBody instance) =>
    <String, dynamic>{
      'customerno': instance.customerno,
      'documents': instance.documents,
    };

KycDocumentSubmissionRequest _$KycDocumentSubmissionRequestFromJson(
  Map<String, dynamic> json,
) => KycDocumentSubmissionRequest(
  transactionType: json['transactionType'] as String,
  screename: json['screename'] as String,
  fullname: json['fullname'] as String,
  tenantId: json['tenantId'] as String,
  jsonBody: KycJsonBody.fromJson(json['jsonBody'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KycDocumentSubmissionRequestToJson(
  KycDocumentSubmissionRequest instance,
) => <String, dynamic>{
  'transactionType': instance.transactionType,
  'screename': instance.screename,
  'fullname': instance.fullname,
  'tenantId': instance.tenantId,
  'jsonBody': instance.jsonBody,
};
