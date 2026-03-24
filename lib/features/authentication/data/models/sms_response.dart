import 'package:json_annotation/json_annotation.dart';

part 'sms_response.g.dart';

@JsonSerializable()
class SmsResponse {
  final bool sentOK;

  SmsResponse({required this.sentOK});

  factory SmsResponse.fromJson(Map<String, dynamic> json) =>
      _$SmsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SmsResponseToJson(this);
}
