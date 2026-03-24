import 'package:json_annotation/json_annotation.dart';

part 'signup_retail_customer_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SignupRetailCustomerRequest {
  final String customerType;
  final String customerCategory;
  final String firstName;
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
  final String? nin;
  final String? tin;
  final String idempotentKey;
  final String tenantId;

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
  });

  factory SignupRetailCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRetailCustomerRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRetailCustomerRequestToJson(this);
}
