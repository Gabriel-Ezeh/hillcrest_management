import 'package:json_annotation/json_annotation.dart';

part 'send_email_request.g.dart';

@JsonSerializable()
class SendEmailRequest {
  final List<Map<String, dynamic>> attachments;
  final String body;
  final String from;
  final String subject;
  final String to;

  SendEmailRequest({
    required this.attachments,
    required this.body,
    required this.from,
    required this.subject,
    required this.to,
  });

  factory SendEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$SendEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendEmailRequestToJson(this);
}
