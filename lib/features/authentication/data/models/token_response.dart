import 'package:json_annotation/json_annotation.dart';

part 'token_response.g.dart';

/// A data model for the token response from the Keycloak API.
/// This class is designed to be serializable to and from JSON.
@JsonSerializable()
class TokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  @JsonKey(name: 'refresh_expires_in')
  final int refreshExpiresIn;

  @JsonKey(name: 'refresh_token')
  final String? refreshToken; // MODIFIED: Made nullable

  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'not-before-policy')
  final int? notBeforePolicy;

  @JsonKey(name: 'session_state')
  final String? sessionState; // MODIFIED: Made nullable

  final String scope;

  TokenResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    this.refreshToken, // MODIFIED: No longer required
    required this.tokenType,
    this.notBeforePolicy,
    this.sessionState, // MODIFIED: No longer required
    required this.scope,
  });

  /// Creates a [TokenResponse] from a JSON map.
  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);

  /// Converts this [TokenResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}
