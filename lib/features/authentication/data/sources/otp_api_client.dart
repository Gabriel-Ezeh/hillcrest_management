import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/send_email_request.dart';
import '../models/sms_response.dart';

part 'otp_api_client.g.dart';

@RestApi()
abstract class OtpApiClient {
  factory OtpApiClient(Dio dio, {String? baseUrl}) = _OtpApiClient;

  /// Generates an OTP for the user's email address and returns it as plain text.
  @GET("generateotp")
  @Headers(<String, dynamic>{'Accept': 'application/json'})
  Future<String> generateEmailOtp({
    @Header("x-tenant-id") required String tenantId,
    @Header("Authorization") required String token,
    @Query("userId") required String email,
  });

  /// Triggers the sending of the generated OTP to the user's email.
  @POST("sendmail")
  @Headers(<String, dynamic>{
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  })
  Future<HttpResponse<String>> sendEmail({
    @Header("x-tenant-id") required String tenantId,
    @Header("Authorization") required String token,
    @Body() required SendEmailRequest body,
  });

  /// Sends an OTP to the user's phone number via SMS.
  @GET('sendsms')
  Future<SmsResponse> sendSmsOtp({
    @Query('message') required String message,
    @Query('recipient') required String phoneNumber,
    @Header('x-tenant-id') required String tenantId,
    @Header('Authorization') required String token,
  });

  /// Validates the OTP for a given user ID (email or phone).
  @GET("validateotp/{userId}/{otp}")
  @Headers(<String, dynamic>{'Accept': 'application/json'})
  Future<HttpResponse<String>> validateOtp({
    @Header("x-tenant-id") required String tenantId,
    @Header("Authorization") required String authorization,
    @Path("userId") required String userId,
    @Path("otp") required String otp,
  });
}
