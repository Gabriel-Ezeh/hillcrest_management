// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_retail_customer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupRetailCustomerRequest _$SignupRetailCustomerRequestFromJson(
  Map<String, dynamic> json,
) => SignupRetailCustomerRequest(
  customerType: json['customerType'] as String,
  customerCategory: json['customerCategory'] as String,
  firstName: json['firstName'] as String,
  middleName: json['middleName'] as String?,
  lastName: json['lastName'] as String,
  gender: json['gender'] as String,
  dob: json['dob'] as String,
  maritalStatus: json['maritalStatus'] as String,
  phoneRef: json['phoneRef'] as String,
  email: json['email'] as String,
  bvn: json['bvn'] as String,
  address: json['address'] as String,
  city: json['city'] as String,
  nin: json['nin'] as String?,
  tin: json['tin'] as String?,
  idempotentKey: json['idempotentKey'] as String,
  tenantId: json['tenantId'] as String,
);

Map<String, dynamic> _$SignupRetailCustomerRequestToJson(
  SignupRetailCustomerRequest instance,
) => <String, dynamic>{
  'customerType': instance.customerType,
  'customerCategory': instance.customerCategory,
  'firstName': instance.firstName,
  'middleName': ?instance.middleName,
  'lastName': instance.lastName,
  'gender': instance.gender,
  'dob': instance.dob,
  'maritalStatus': instance.maritalStatus,
  'phoneRef': instance.phoneRef,
  'email': instance.email,
  'bvn': instance.bvn,
  'address': instance.address,
  'city': instance.city,
  'nin': ?instance.nin,
  'tin': ?instance.tin,
  'idempotentKey': instance.idempotentKey,
  'tenantId': instance.tenantId,
};
