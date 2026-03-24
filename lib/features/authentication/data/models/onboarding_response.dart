import 'package:json_annotation/json_annotation.dart';

part 'onboarding_response.g.dart';

@JsonSerializable()
class OnboardingResponse {
  // Assuming the response JSON has a key like "requestId"
  final String requestId;

  OnboardingResponse({required this.requestId});

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingResponseToJson(this);
}
