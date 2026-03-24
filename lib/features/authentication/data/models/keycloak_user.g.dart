// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keycloak_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeycloakUser _$KeycloakUserFromJson(Map<String, dynamic> json) => KeycloakUser(
  id: json['id'] as String,
  username: json['username'] as String?,
  email: json['email'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  attributes: json['attributes'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$KeycloakUserToJson(KeycloakUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'attributes': instance.attributes,
    };
