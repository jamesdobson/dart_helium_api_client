import 'package:helium_api_client/src/converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'oracle_prices.g.dart';

/// A data point representing the cost of 1 HNT in USD at a given time.
@JsonSerializable()
class HeliumOraclePrice {
  /// The price of 1 HNT in thousandths of a DC or hundred-millionths of a USD.
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

  /// Creates a new instance.
  HeliumOraclePrice({
    required this.price,
    required this.block,
    required this.timestamp,
  });

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumOraclePrice.fromJson(Map<String, dynamic> json) =>
      _$HeliumOraclePriceFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumOraclePriceToJson(this);
}

/// Statistics about the price of 1 HNT in USD over a period of time.
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

  /// Creates a new instance.
  HeliumOraclePriceStats({
    required this.avg,
    required this.max,
    required this.median,
    required this.min,
    required this.stddev,
  });

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumOraclePriceStats.fromJson(Map<String, dynamic> json) =>
      _$HeliumOraclePriceStatsFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumOraclePriceStatsToJson(this);
}

/// A data point representing a predicted price of 1 HNT in USD at some time
/// in the future.
@JsonSerializable()
class HeliumOraclePricePrediction {
  /// The predicted price of 1 HNT in thousandths of a DC or
  /// ten-millionths of a USD.
  final int price;

  /// The time that the predicted price may take effect.
  @JsonKey(
    fromJson: heliumBlockTimeFromJson,
    toJson: heliumBlockTimeToJson,
  )
  final DateTime time;

  /// The approximate predicted price of 1 HNT in USD.
  double get dollars => price / 100000000;

  /// Creates a new instance.
  HeliumOraclePricePrediction({
    required this.price,
    required this.time,
  });

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumOraclePricePrediction.fromJson(Map<String, dynamic> json) =>
      _$HeliumOraclePricePredictionFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumOraclePricePredictionToJson(this);
}
