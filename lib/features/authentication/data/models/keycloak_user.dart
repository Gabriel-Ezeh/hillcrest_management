import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'keycloak_user.g.dart';

@HiveType(typeId: 0) // Assign a unique type ID for Hive
@JsonSerializable()
class KeycloakUser {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? username;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? firstName;

  @HiveField(4)
  final String? lastName;

  @HiveField(5)
  final Map<String, dynamic>? attributes;

  KeycloakUser({
    required this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.attributes,
  });

  factory KeycloakUser.fromJson(Map<String, dynamic> json) => _$KeycloakUserFromJson(json);

  Map<String, dynamic> toJson() => _$KeycloakUserToJson(this);
}
