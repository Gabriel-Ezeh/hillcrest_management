import 'package:json_annotation/json_annotation.dart';

part 'bvn_validation_request.g.dart';

@JsonSerializable()
class BvnValidationRequest {
  final String bvn;
  final String firstname;
  final String lastname;
  final String dob;

  BvnValidationRequest({
    required this.bvn,
    required this.firstname,
    required this.lastname,
    required this.dob,
  });

  factory BvnValidationRequest.fromJson(Map<String, dynamic> json) =>
      _$BvnValidationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BvnValidationRequestToJson(this);
}
