import 'package:helium_api_client/src/converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'oracle_prices.g.dart';

@JsonSerializable()
class HeliumOraclePrice {
  /// The current price of 1 HNT in thousandths of a DC or
  /// ten-millionths of a USD.
  final int price;

  /// The block at which the price took effect.
  final int block;

  /// The time at which the price took effect.
  @JsonKey(
    fromJson: heliumTimestampFromJson,
    toJson: heliumTimestampToJson,
  )
  final DateTime timestamp;

  /// The approximate price of 1 HNT in USD.
  double get dollars => price / 100000000;

  HeliumOraclePrice({
    required this.price,
    required this.block,
    required this.timestamp,
  });

  factory HeliumOraclePrice.fromJson(Map<String, dynamic> json) =>
      _$HeliumOraclePriceFromJson(json);

  Map<String, dynamic> toJson() => _$HeliumOraclePriceToJson(this);
}
