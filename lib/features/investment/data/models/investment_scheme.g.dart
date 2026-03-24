// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_scheme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvestmentScheme _$InvestmentSchemeFromJson(Map<String, dynamic> json) =>
    InvestmentScheme(
      schemeId: (json['schemeId'] as num?)?.toInt(),
      schemeName: json['schemeName'] as String?,
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      totalUnits: (json['totalUnits'] as num?)?.toDouble(),
      bidPrice: (json['bidPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$InvestmentSchemeToJson(InvestmentScheme instance) =>
    <String, dynamic>{
      'schemeId': instance.schemeId,
      'schemeName': instance.schemeName,
      'offerPrice': instance.offerPrice,
      'totalUnits': instance.totalUnits,
      'bidPrice': instance.bidPrice,
    };
