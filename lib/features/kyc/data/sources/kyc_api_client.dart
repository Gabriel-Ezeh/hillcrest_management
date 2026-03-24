import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/bvn_validation_request.dart';
import '../models/signup_retail_customer_request.dart';
import '../models/kyc_document_submission_request.dart';

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
}
