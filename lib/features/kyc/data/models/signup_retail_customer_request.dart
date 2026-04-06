import 'package:json_annotation/json_annotation.dart';

part 'signup_retail_customer_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SignupRetailCustomerRequest {
  final String customerType;
  
  @JsonKey(name: 'customercategory')
  final String customerCategory;
  
  final String firstName;
  
  @JsonKey(name: 'otherName') 
  final String? middleName;
  
  final String lastName;
  final String gender;
  final String dob;
  final String maritalStatus;
  final String phoneRef;
  final String email;
  final String bvn;
  final String address;
  final String city;
  
  @JsonKey(name: 'nin')
  final String? nin;
  
  @JsonKey(name: 'tin')
  final String? tin;
  
  @JsonKey(name: 'idempotentkey')
  final String idempotentKey;
  
  @JsonKey(name: 'tenantid')
  final String tenantId;

  final String? bankers;
  
  @JsonKey(name: 'bankaccountno')
  final String? bankAccountNo;
  
  @JsonKey(name: 'bankaccountname')
  final String? bankAccountName;

  @JsonKey(name: 'bankcode')
  final String? bankCode;
  
  @JsonKey(name: 'bankname')
  final String? bankName;

  SignupRetailCustomerRequest({
    required this.customerType,
    required this.customerCategory,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.gender,
    required this.dob,
    required this.maritalStatus,
    required this.phoneRef,
    required this.email,
    required this.bvn,
    required this.address,
    required this.city,
    this.nin,
    this.tin,
    required this.idempotentKey,
    required this.tenantId,
    this.bankers,
    this.bankAccountNo,
    this.bankAccountName,
    this.bankCode,
    this.bankName,
  });

  factory SignupRetailCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRetailCustomerRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRetailCustomerRequestToJson(this);
}
