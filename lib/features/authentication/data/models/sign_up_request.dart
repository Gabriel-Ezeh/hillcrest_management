import 'package:json_annotation/json_annotation.dart';

part 'sign_up_request.g.dart';

// Represents a single credential object for Keycloak
@JsonSerializable()
class KeycloakCredential {
  final String type;
  final String value;
  final bool temporary;

  KeycloakCredential({
    required this.type,
    required this.value,
    this.temporary = false,
  });

  factory KeycloakCredential.fromJson(Map<String, dynamic> json) =>
      _$KeycloakCredentialFromJson(json);

  Map<String, dynamic> toJson() => _$KeycloakCredentialToJson(this);
}

// Represents the request body for creating a new user in Keycloak
@JsonSerializable()
class SignUpRequest {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool enabled;
  final bool emailVerified;
  final List<KeycloakCredential> credentials;
  final Map<String, String> attributes;

  SignUpRequest({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.credentials,
    required this.attributes,
    this.enabled = true,
    this.emailVerified = true,
  });

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpRequestToJson(this);
}
