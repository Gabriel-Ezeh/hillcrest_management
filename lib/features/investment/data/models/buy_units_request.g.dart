// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buy_units_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuyUnitsRequest _$BuyUnitsRequestFromJson(Map<String, dynamic> json) =>
    BuyUnitsRequest(
      schemeId: json['schemeId'] as String,
      investorId: json['investorId'] as String,
      transUnits: json['transUnits'] as String,
    );

Map<String, dynamic> _$BuyUnitsRequestToJson(BuyUnitsRequest instance) =>
    <String, dynamic>{
      'schemeId': instance.schemeId,
      'investorId': instance.investorId,
      'transUnits': instance.transUnits,
    };
