import 'package:json_annotation/json_annotation.dart';

part 'buy_units_request.g.dart';

@JsonSerializable()
class BuyUnitsRequest {
  final String schemeId;
  final String investorId;
  final String transUnits;

  BuyUnitsRequest({
    required this.schemeId,
    required this.investorId,
    required this.transUnits,
  });

  factory BuyUnitsRequest.fromJson(Map<String, dynamic> json) =>
      _$BuyUnitsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BuyUnitsRequestToJson(this);
}

