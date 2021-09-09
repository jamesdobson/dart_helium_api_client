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
