// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeliumTransactionAddGatewayV1 _$HeliumTransactionAddGatewayV1FromJson(
        Map<String, dynamic> json) =>
    HeliumTransactionAddGatewayV1(
      type: heliumTransactionTypeFromJson(json['type'] as String),
      hash: json['hash'] as String,
      height: json['height'] as int,
      time: json['time'] as int,
      fee: json['fee'] as int,
      stakingFee: json['staking_fee'] as int,
      gateway: json['gateway'] as String,
      owner: json['owner'] as String,
      payer: json['payer'] as String,
    );

Map<String, dynamic> _$HeliumTransactionAddGatewayV1ToJson(
        HeliumTransactionAddGatewayV1 instance) =>
    <String, dynamic>{
      'type': heliumTransactionTypeToJson(instance.type),
      'hash': instance.hash,
      'height': instance.height,
      'time': instance.time,
      'fee': instance.fee,
      'staking_fee': instance.stakingFee,
      'gateway': instance.gateway,
      'owner': instance.owner,
      'payer': instance.payer,
    };

HeliumTransactionAssertLocationV1 _$HeliumTransactionAssertLocationV1FromJson(
        Map<String, dynamic> json) =>
    HeliumTransactionAssertLocationV1(
      type: heliumTransactionTypeFromJson(json['type'] as String),
      hash: json['hash'] as String,
      height: json['height'] as int,
      time: json['time'] as int,
      fee: json['fee'] as int,
      stakingFee: json['staking_fee'] as int,
      gateway: json['gateway'] as String,
      owner: json['owner'] as String,
      payer: json['payer'] as String,
      location: json['location'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      nonce: json['nonce'] as int,
    );

Map<String, dynamic> _$HeliumTransactionAssertLocationV1ToJson(
        HeliumTransactionAssertLocationV1 instance) =>
    <String, dynamic>{
      'type': heliumTransactionTypeToJson(instance.type),
      'hash': instance.hash,
      'height': instance.height,
      'time': instance.time,
      'fee': instance.fee,
      'staking_fee': instance.stakingFee,
      'gateway': instance.gateway,
      'owner': instance.owner,
      'payer': instance.payer,
      'location': instance.location,
      'lat': instance.lat,
      'lng': instance.lng,
      'nonce': instance.nonce,
    };

HeliumTransactionAssertLocationV2 _$HeliumTransactionAssertLocationV2FromJson(
        Map<String, dynamic> json) =>
    HeliumTransactionAssertLocationV2(
      type: heliumTransactionTypeFromJson(json['type'] as String),
      hash: json['hash'] as String,
      height: json['height'] as int,
      time: json['time'] as int,
      fee: json['fee'] as int,
      stakingFee: json['staking_fee'] as int,
      gateway: json['gateway'] as String,
      owner: json['owner'] as String,
      payer: json['payer'] as String,
      location: json['location'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      elevation: json['elevation'] as int,
      gain: json['gain'] as int,
      nonce: json['nonce'] as int,
    );

Map<String, dynamic> _$HeliumTransactionAssertLocationV2ToJson(
        HeliumTransactionAssertLocationV2 instance) =>
    <String, dynamic>{
      'type': heliumTransactionTypeToJson(instance.type),
      'hash': instance.hash,
      'height': instance.height,
      'time': instance.time,
      'fee': instance.fee,
      'staking_fee': instance.stakingFee,
      'gateway': instance.gateway,
      'owner': instance.owner,
      'payer': instance.payer,
      'location': instance.location,
      'lat': instance.lat,
      'lng': instance.lng,
      'elevation': instance.elevation,
      'gain': instance.gain,
      'nonce': instance.nonce,
    };
