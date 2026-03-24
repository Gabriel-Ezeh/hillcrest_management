import 'package:json_annotation/json_annotation.dart';

part 'investment_scheme.g.dart';

@JsonSerializable()
class InvestmentScheme {
  final int? schemeId;
  final String? schemeName;
  final double? offerPrice;
  final double? totalUnits;  // Changed to double since API returns decimal
  final double? bidPrice;

  InvestmentScheme({
    this.schemeId,
    this.schemeName,
    this.offerPrice,
    this.totalUnits,
    this.bidPrice,

  });

  factory InvestmentScheme.fromJson(Map<String, dynamic> json) =>
      _$InvestmentSchemeFromJson(json);

  Map<String, dynamic> toJson() => _$InvestmentSchemeToJson(this);
}