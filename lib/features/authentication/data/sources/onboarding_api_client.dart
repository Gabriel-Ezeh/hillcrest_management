import 'package:dio/dio.dart' hide Headers; // Keep this to avoid conflicts
import 'package:retrofit/retrofit.dart';
import '../../../../utils/constants/api_constants.dart';
import '../models/onboarding_response.dart';

part 'onboarding_api_client.g.dart';

@RestApi()
abstract class OnboardingApiClient {
  factory OnboardingApiClient(Dio dio, {String? baseUrl}) = _OnboardingApiClient;

  // This corresponds to Step 2 of the sign-up flow.
  @POST(ApiConstants.initiateOnboarding)
  @Headers(<String, dynamic>{ // MODIFIED: Set both headers
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  })
  Future<OnboardingResponse> initiateOnboarding({
    @Path("firstName") required String firstName,
    @Path("lastName") required String lastName,
    @Header("x-tenant-id") required String tenantId,
    @Body() required Map<String, dynamic> body, // MODIFIED: Added required empty body
  });
}
