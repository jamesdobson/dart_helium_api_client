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

@JsonSerializable()
class HeliumOraclePriceStats {
  /// The arithmetic mean price of 1 HNT in USD.
  final double avg;

  /// The maximum price of 1 HNT in USD.
  final double max;

  /// The median price of 1 HNT in USD.
  final double median;

  /// The minimum price of 1 HNT in USD.
  final double min;

  /// The standard deviation of the price of 1 HNT.
  final double stddev;

  HeliumOraclePriceStats({
    required this.avg,
    required this.max,
    required this.median,
    required this.min,
    required this.stddev,
  });

  factory HeliumOraclePriceStats.fromJson(Map<String, dynamic> json) =>
      _$HeliumOraclePriceStatsFromJson(json);

  Map<String, dynamic> toJson() => _$HeliumOraclePriceStatsToJson(this);
}
