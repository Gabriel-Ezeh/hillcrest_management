import 'package:json_annotation/json_annotation.dart';

part 'portfolio_holding.g.dart';

@JsonSerializable()
class PortfolioHolding {
  final int? schemeId;
  final String? schemeName;
  final double? netUnits;
  final double? currentBidPrice;
  final double? currentValue;

  PortfolioHolding({
    this.schemeId,
    this.schemeName,
    this.netUnits,
    this.currentBidPrice,
    this.currentValue,
  });

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) =>
      _$PortfolioHoldingFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioHoldingToJson(this);

  String getFormattedValue() => currentValue != null ? '₦${currentValue!.toStringAsFixed(2)}' : '₦0.00';
  String getFormattedUnits() => netUnits != null ? netUnits!.toStringAsFixed(0) : '0';
  double getTotalValue() => currentValue ?? 0.0;
}

