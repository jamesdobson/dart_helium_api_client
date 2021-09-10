// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oracle_prices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeliumOraclePrice _$HeliumOraclePriceFromJson(Map<String, dynamic> json) =>
    HeliumOraclePrice(
      price: json['price'] as int,
      block: json['block'] as int,
      timestamp: heliumTimestampFromJson(json['timestamp'] as String),
    );

Map<String, dynamic> _$HeliumOraclePriceToJson(HeliumOraclePrice instance) =>
    <String, dynamic>{
      'price': instance.price,
      'block': instance.block,
      'timestamp': heliumTimestampToJson(instance.timestamp),
    };

HeliumOraclePriceStats _$HeliumOraclePriceStatsFromJson(
        Map<String, dynamic> json) =>
    HeliumOraclePriceStats(
      avg: (json['avg'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      median: (json['median'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      stddev: (json['stddev'] as num).toDouble(),
    );

Map<String, dynamic> _$HeliumOraclePriceStatsToJson(
        HeliumOraclePriceStats instance) =>
    <String, dynamic>{
      'avg': instance.avg,
      'max': instance.max,
      'median': instance.median,
      'min': instance.min,
      'stddev': instance.stddev,
    };

HeliumOraclePricePredictions _$HeliumOraclePricePredictionsFromJson(
        Map<String, dynamic> json) =>
    HeliumOraclePricePredictions(
      price: json['price'] as int,
      time: heliumBlockTimeFromJson(json['time'] as int),
    );

Map<String, dynamic> _$HeliumOraclePricePredictionsToJson(
        HeliumOraclePricePredictions instance) =>
    <String, dynamic>{
      'price': instance.price,
      'time': heliumBlockTimeToJson(instance.time),
    };
