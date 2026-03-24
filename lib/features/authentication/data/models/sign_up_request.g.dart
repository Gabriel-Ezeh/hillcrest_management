// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeycloakCredential _$KeycloakCredentialFromJson(Map<String, dynamic> json) =>
    KeycloakCredential(
      type: json['type'] as String,
      value: json['value'] as String,
      temporary: json['temporary'] as bool? ?? false,
    );

Map<String, dynamic> _$KeycloakCredentialToJson(KeycloakCredential instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'temporary': instance.temporary,
    };

SignUpRequest _$SignUpRequestFromJson(Map<String, dynamic> json) =>
    SignUpRequest(
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => KeycloakCredential.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: Map<String, String>.from(json['attributes'] as Map),
      enabled: json['enabled'] as bool? ?? true,
      emailVerified: json['emailVerified'] as bool? ?? true,
    );

Map<String, dynamic> _$SignUpRequestToJson(SignUpRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'enabled': instance.enabled,
      'emailVerified': instance.emailVerified,
      'credentials': instance.credentials,
      'attributes': instance.attributes,
    };
