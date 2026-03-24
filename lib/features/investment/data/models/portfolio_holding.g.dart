// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_holding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortfolioHolding _$PortfolioHoldingFromJson(Map<String, dynamic> json) =>
    PortfolioHolding(
      schemeId: (json['schemeId'] as num?)?.toInt(),
      schemeName: json['schemeName'] as String?,
      netUnits: (json['netUnits'] as num?)?.toDouble(),
      currentBidPrice: (json['currentBidPrice'] as num?)?.toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PortfolioHoldingToJson(PortfolioHolding instance) =>
    <String, dynamic>{
      'schemeId': instance.schemeId,
      'schemeName': instance.schemeName,
      'netUnits': instance.netUnits,
      'currentBidPrice': instance.currentBidPrice,
      'currentValue': instance.currentValue,
    };
