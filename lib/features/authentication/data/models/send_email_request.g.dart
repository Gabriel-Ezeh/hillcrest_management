// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_email_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendEmailRequest _$SendEmailRequestFromJson(Map<String, dynamic> json) =>
    SendEmailRequest(
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      body: json['body'] as String,
      from: json['from'] as String,
      subject: json['subject'] as String,
      to: json['to'] as String,
    );

Map<String, dynamic> _$SendEmailRequestToJson(SendEmailRequest instance) =>
    <String, dynamic>{
      'attachments': instance.attachments,
      'body': instance.body,
      'from': instance.from,
      'subject': instance.subject,
      'to': instance.to,
    };
