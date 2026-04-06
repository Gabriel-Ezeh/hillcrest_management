import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/bvn_validation_request.dart';
import '../models/signup_retail_customer_request.dart';
import '../models/account_lookup_response.dart';
import '../models/customer_details_v4_response.dart';

import '../models/bank.dart';

part 'kyc_api_client.g.dart';

@RestApi()
abstract class KycApiClient {
  factory KycApiClient(Dio dio, {String? baseUrl}) = _KycApiClient;

  @POST("validatecustomerbvn")
  Future<void> validateBvn(
    @Header("X-TENANTID") String tenantId,
    @Header("Authorization") String token,
    @Body() BvnValidationRequest body,
  );

  @POST("signupRetailCustomer")
  Future<HttpResponse> signupRetailCustomer(
    @Header("X-TENANTID") String tenantId,
    @Header("Authorization") String token,
    @Body() SignupRetailCustomerRequest body,
  );

  @POST("submitTransaction")
  Future<HttpResponse> submitKycDocuments(
    @Header("X-TenantId") String tenantId,
    @Header("Authorization") String token,
    @Query("transactiontype") String transactionType,
    @Query("screenname") String screenName,
    @Query("fullname") String fullName,
    @Body() Map<String, dynamic> body,
  );

  // Fetch all banks
  @GET('getallbanks')
  Future<List<Bank>> getAllBanks(
    @Header('X-TENANTID') String tenantId,
    @Header('Authorization') String token,
  );

  // Fetch customer details (used for redeem bank account details)
  @GET('getCustomerDetailsv4')
  Future<CustomerDetailsV4Response> getCustomerDetailsV4(
    @Header('X-TenantId') String tenantId,
    @Header('Authorization') String token,
    @Query('CustomerNo') String customerNo,
  );

  // Lookup account name
  @GET('accountNameLookup')
  Future<AccountLookupResponse> accountNameLookup(
    @Header('X-TENANTID') String tenantId,
    @Header('Authorization') String token,
    @Header('content-type') String contentType,
    @Query('nuban') String nuban,
    @Query('bankcode') String bankCode,
  );
}
