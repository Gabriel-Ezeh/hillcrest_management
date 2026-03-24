// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bvn_validation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BvnValidationRequest _$BvnValidationRequestFromJson(
  Map<String, dynamic> json,
) => BvnValidationRequest(
  bvn: json['bvn'] as String,
  firstname: json['firstname'] as String,
  lastname: json['lastname'] as String,
  dob: json['dob'] as String,
);

Map<String, dynamic> _$BvnValidationRequestToJson(
  BvnValidationRequest instance,
) => <String, dynamic>{
  'bvn': instance.bvn,
  'firstname': instance.firstname,
  'lastname': instance.lastname,
  'dob': instance.dob,
};
