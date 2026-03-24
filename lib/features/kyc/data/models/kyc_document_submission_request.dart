import 'dart:typed_data';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'kyc_document_submission_request.g.dart';

// Helper functions for Uint8List serialization to/from base64
String _uint8ListToJson(Uint8List data) => base64Encode(data);
Uint8List _uint8ListFromJson(String json) => base64Decode(json);

// Represents the innermost document object
@JsonSerializable()
class KycDocument {
  final String documentType;
  final String documentReference;
  @JsonKey(
    fromJson: _uint8ListFromJson,
    toJson: _uint8ListToJson,
  )
  final Uint8List documentImage;
  final String documentComments;
  final bool documentConfirmed;
  final bool documentValid;
  final String? documentIssueDate;
  final String? documentExpiryDate;
  final String? documentConfirmedBy;
  final String? documentConfirmedDate;

  KycDocument({
    required this.documentType,
    required this.documentReference,
    required this.documentImage,
    this.documentComments = '',
    this.documentConfirmed = false,
    this.documentValid = false,
    this.documentIssueDate,
    this.documentExpiryDate,
    this.documentConfirmedBy,
    this.documentConfirmedDate,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$KycDocumentToJson(this);
}

// Represents the nested 'jsonBody' object
@JsonSerializable()
class KycJsonBody {
  final String customerno;
  final List<KycDocument> documents;

  KycJsonBody({required this.customerno, required this.documents});

  factory KycJsonBody.fromJson(Map<String, dynamic> json) =>
      _$KycJsonBodyFromJson(json);

  Map<String, dynamic> toJson() => _$KycJsonBodyToJson(this);
}

// Represents the main request body
@JsonSerializable()
class KycDocumentSubmissionRequest {
  final String transactionType;
  final String screename;
  final String fullname;
  final String tenantId;
  final KycJsonBody jsonBody;

  KycDocumentSubmissionRequest({
    required this.transactionType,
    required this.screename,
    required this.fullname,
    required this.tenantId,
    required this.jsonBody,
  });

  factory KycDocumentSubmissionRequest.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentSubmissionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$KycDocumentSubmissionRequestToJson(this);
}