// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_retail_customer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupRetailCustomerRequest _$SignupRetailCustomerRequestFromJson(
  Map<String, dynamic> json,
) => SignupRetailCustomerRequest(
  customerType: json['customerType'] as String,
  customerCategory: json['customercategory'] as String,
  firstName: json['firstName'] as String,
  middleName: json['otherName'] as String?,
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
  idempotentKey: json['idempotentkey'] as String,
  tenantId: json['tenantid'] as String,
  bankers: json['bankers'] as String?,
  bankAccountNo: json['bankaccountno'] as String?,
  bankAccountName: json['bankaccountname'] as String?,
  bankCode: json['bankcode'] as String?,
  bankName: json['bankname'] as String?,
);

Map<String, dynamic> _$SignupRetailCustomerRequestToJson(
  SignupRetailCustomerRequest instance,
) => <String, dynamic>{
  'customerType': instance.customerType,
  'customercategory': instance.customerCategory,
  'firstName': instance.firstName,
  'otherName': ?instance.middleName,
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
  'idempotentkey': instance.idempotentKey,
  'tenantid': instance.tenantId,
  'bankers': ?instance.bankers,
  'bankaccountno': ?instance.bankAccountNo,
  'bankaccountname': ?instance.bankAccountName,
  'bankcode': ?instance.bankCode,
  'bankname': ?instance.bankName,
};
