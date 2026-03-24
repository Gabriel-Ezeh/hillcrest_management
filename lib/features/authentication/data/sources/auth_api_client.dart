import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../../../../utils/constants/api_constants.dart';
import '../models/keycloak_user.dart';
import '../models/sign_up_request.dart';
import '../models/token_response.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  // --- STANDARD AUTH --- //

  @POST(ApiConstants.keycloakTokenEndpoint)
  @FormUrlEncoded()
  Future<TokenResponse> login({
    @Path("realm") required String realm,
    @Field("grant_type") required String grantType,
    @Field("client_id") required String clientId,
    @Field("client_secret") required String clientSecret,
    @Field("username") required String username,
    @Field("password") required String password,
  });

  @POST(ApiConstants.keycloakTokenEndpoint)
  @FormUrlEncoded()
  Future<TokenResponse> refreshToken({
    @Path("realm") required String realm,
    @Field("grant_type") required String grantType,
    @Field("client_id") required String clientId,
    @Field("client_secret") required String clientSecret,
    @Field("refresh_token") required String refreshToken,
  });

  @POST(ApiConstants.keycloakLogoutEndpoint)
  @FormUrlEncoded()
  Future<void> logout({
    @Path("realm") required String realm,
    @Field("client_id") required String clientId,
    @Field("client_secret") required String clientSecret,
    @Field("refresh_token") required String refreshToken,
  });




  // --- ADMIN API --- //

  @GET(ApiConstants.keycloakGetUsers)
  Future<List<KeycloakUser>> getUsers({
    @Path("realm") required String realm,
    @Query("username") String? username,
    @Query("email") String? email,
    @Query("first") int? first,
    @Query("max") int? max,
    @Query("q") String? q,
    @Header("Authorization") required String adminToken,
  });

  @GET(ApiConstants.keycloakUpdateUser)
  Future<KeycloakUser> getUserById({
    @Path("realm") required String realm,
    @Path("userId") required String userId,
    @Header("Authorization") required String adminToken,
  });

  // ADDED: Get a single user by their unique ID
  @PUT("/auth/admin/realms/{realm}/users/{id}")
  Future<void> updateUserAttributes(
      @Path("realm") String realm,
      @Path("id") String userId, // Ensure this matches your @Path ("id" or "userId")
      @Body() Map<String, dynamic> attributes,
      @Header("Authorization") String adminToken,
      );


  @POST(ApiConstants.keycloakCreateUser)
  Future<void> createUser({
    @Path("realm") required String realm,
    @Body() required SignUpRequest user,
    @Header("Authorization") required String adminToken,
  });

  @PUT(ApiConstants.keycloakUpdateUser)
  Future<void> updateUser({
    @Path("realm") required String realm,
    @Path("userId") required String userId,
    @Body() required Map<String, dynamic> attributes,
    @Header("Authorization") required String adminToken,
  });

  // ADDED: Method to trigger the password reset email
  @PUT("${ApiConstants.keycloakGetUsers}/{userId}/execute-actions-email")
  @Headers(<String, dynamic>{
    "Content-Type": "application/json",
  })
  Future<void> executeActionsEmail({
    @Path("realm") required String realm,
    @Path("userId") required String userId,
    @Header("Authorization") required String adminToken,
    @Body() required List<String> actions,
  });


  @POST("/auth/realms/{realm}/protocol/openid-connect/token")
  @FormUrlEncoded()
  Future<TokenResponse> getClientCredentialsToken({
    @Path("realm") required String realm,
    @Field("grant_type") required String grantType,
    @Field("client_id") required String clientId,
    @Field("client_secret") required String clientSecret,
  });


  @POST("/auth/realms/{realm}/protocol/openid-connect/token")
  @FormUrlEncoded()
  Future<TokenResponse> getNeosServiceToken({
    @Path("realm") required String realm,
    @Field("grant_type") required String grantType,
    @Field("client_id") required String clientId,
    @Field("client_secret") required String clientSecret,
    @Field("username") required String username,
    @Field("password") required String password,
  });
}
