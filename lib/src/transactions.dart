import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';

part 'transactions.g.dart';

abstract class HeliumTransaction {
  /// The type of transaction.
  @JsonKey(
    toJson: heliumTransactionTypeToJson,
    fromJson: heliumTransactionTypeFromJson,
  )
  final HeliumTransactionType type;

  /// The transaction hash.
  final String hash;

  /// The block containing the transaction.
  final int height;

  /// TODO: Add description.
  final int time;

  HeliumTransaction({
    required this.type,
    required this.hash,
    required this.height,
    required this.time,
  });

  static final Map<HeliumTransactionType, Function> _deserializerMap = {
    HeliumTransactionType.ADD_GATEWAY_V1: (json) =>
        HeliumTransactionAddGatewayV1.fromJson(json),
    HeliumTransactionType.ASSERT_LOCATION_V1: (json) =>
        HeliumTransactionAssertLocationV1.fromJson(json),
    HeliumTransactionType.ASSERT_LOCATION_V2: (json) =>
        HeliumTransactionAssertLocationV2.fromJson(json),
  };

  factory HeliumTransaction.fromJson(Map<String, dynamic> json) {
    final type = HeliumTransactionType.get(json['type']);
    final deserializer = _deserializerMap[type];

    if (deserializer == null) {
      return HeliumTransactionUnknown.fromJson(json);
    }

    return deserializer(json);
  }

  Map<String, dynamic> toJson();
}

class HeliumTransactionType {
  final String value;

  const HeliumTransactionType._internal(this.value);

  factory HeliumTransactionType.get(String value) {
    var type = _lookup[value];

    if (type == null) {
      type = HeliumTransactionType._internal(value);
      _lookup[value] = type;
    }

    return type;
  }

  @override
  String toString() => 'HeliumTransactionType.$value';

  static const ADD_GATEWAY_V1 =
      HeliumTransactionType._internal('add_gateway_v1');
  static const ASSERT_LOCATION_V1 =
      HeliumTransactionType._internal('assert_location_v1');
  static const ASSERT_LOCATION_V2 =
      HeliumTransactionType._internal('assert_location_v2');
  static const REWARDS_V1 = HeliumTransactionType._internal('rewards_v1');
  static const REWARDS_V2 = HeliumTransactionType._internal('rewards_v2');
  static const TOKEN_BURN_V1 = HeliumTransactionType._internal('token_burn_v1');

  static final Map<String, HeliumTransactionType> _lookup = {
    'add_gateway_v1': ADD_GATEWAY_V1,
    'assert_location_v1': ASSERT_LOCATION_V1,
    'assert_location_v2': ASSERT_LOCATION_V2,
    'rewards_v1': REWARDS_V1,
    'rewards_v2': REWARDS_V2,
    'token_burn_v1': TOKEN_BURN_V1,
  };
}

HeliumTransactionType heliumTransactionTypeFromJson(String value) {
  return HeliumTransactionType.get(value);
}

String heliumTransactionTypeToJson(HeliumTransactionType type) {
  return type.value;
}

class HeliumTransactionUnknown extends HeliumTransaction {
  /// The other fields in the transaction record.
  final Map<String, dynamic> data;

  HeliumTransactionUnknown({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required int time,
    required this.data,
  }) : super(type: type, hash: hash, height: height, time: time);

  factory HeliumTransactionUnknown.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = HashMap();

    data.addAll(json);

    final type = heliumTransactionTypeFromJson(data.remove('type'));
    final hash = data.remove('hash');
    final height = data.remove('height');
    final time = data.remove('time');

    return HeliumTransactionUnknown(
      type: type,
      hash: hash,
      height: height,
      time: time,
      data: data,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = HashMap();

    json.addAll(data);
    json['type'] = type;
    json['hash'] = hash;
    json['height'] = height;
    json['time'] = time;

    return json;
  }
}

@JsonSerializable()
class HeliumTransactionAddGatewayV1 extends HeliumTransaction {
  /// The transaction fee, in DC.
  final int fee;

  /// The fee, in DC, to add the gateway.
  /// See: https://docs.helium.com/blockchain/transaction-fees/
  @JsonKey(name: 'staking_fee')
  final int stakingFee;

  /// The address of the gateway to add.
  /// This is the address used in the Hotspots API.
  final String gateway;

  /// The wallet address of the gateway owner.
  /// This is the address to which gateway rewards will be sent.
  final String owner;

  /// The wallet address of the fee payer.
  /// Typically, this will be the address of the hotspot maker's wallet since
  /// they pay the initial hotspot fees.
  final String payer;

  HeliumTransactionAddGatewayV1({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required int time,
    required this.fee,
    required this.stakingFee,
    required this.gateway,
    required this.owner,
    required this.payer,
  }) : super(type: type, hash: hash, height: height, time: time);

  factory HeliumTransactionAddGatewayV1.fromJson(Map<String, dynamic> json) =>
      _$HeliumTransactionAddGatewayV1FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HeliumTransactionAddGatewayV1ToJson(this);
}

@JsonSerializable()
class HeliumTransactionAssertLocationV1 extends HeliumTransaction {
  /// The transaction fee, in DC.
  final int fee;

  /// The fee, in DC, to add the gateway.
  /// See: https://docs.helium.com/blockchain/transaction-fees/
  @JsonKey(name: 'staking_fee')
  final int stakingFee;

  /// The address of the gateway to add.
  /// This is the address used in the Hotspots API.
  final String gateway;

  /// The wallet address of the gateway owner.
  final String owner;

  /// The wallet address of the fee payer.
  /// For the first location assertion, this will be the address of the hotspot
  /// maker's wallet since they pay the initial hotspot fees. Subsequent
  /// location assertions will be from a different wallet.
  final String payer;

  /// The H3 index of the asserted location.
  final String location;

  /// The latitude in degrees.
  final double lat;

  /// The longitude in degrees.
  final double lng;

  final int nonce;

  HeliumTransactionAssertLocationV1({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required int time,
    required this.fee,
    required this.stakingFee,
    required this.gateway,
    required this.owner,
    required this.payer,
    required this.location,
    required this.lat,
    required this.lng,
    required this.nonce,
  }) : super(type: type, hash: hash, height: height, time: time);

  factory HeliumTransactionAssertLocationV1.fromJson(
          Map<String, dynamic> json) =>
      _$HeliumTransactionAssertLocationV1FromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$HeliumTransactionAssertLocationV1ToJson(this);
}

@JsonSerializable()
class HeliumTransactionAssertLocationV2 extends HeliumTransaction {
  /// The transaction fee, in DC.
  final int fee;

  /// The fee, in DC, to add the gateway.
  /// See: https://docs.helium.com/blockchain/transaction-fees/
  @JsonKey(name: 'staking_fee')
  final int stakingFee;

  /// The address of the gateway to add.
  /// This is the address used in the Hotspots API.
  final String gateway;

  /// The wallet address of the gateway owner.
  final String owner;

  /// The wallet address of the fee payer.
  /// For the first location assertion, this will be the address of the hotspot
  /// maker's wallet since they pay the initial hotspot fees. Subsequent
  /// location assertions will be from a different wallet.
  final String payer;

  /// The H3 index of the asserted location.
  final String location;

  /// The latitude in degrees.
  final double lat;

  /// The longitude in degrees.
  final double lng;

  /// The antenna elevation above ground level in metres.
  final int elevation;

  /// The antenna gain in tenths of a dBi.
  final int gain;

  final int nonce;

  HeliumTransactionAssertLocationV2({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required int time,
    required this.fee,
    required this.stakingFee,
    required this.gateway,
    required this.owner,
    required this.payer,
    required this.location,
    required this.lat,
    required this.lng,
    required this.elevation,
    required this.gain,
    required this.nonce,
  }) : super(type: type, hash: hash, height: height, time: time);

  factory HeliumTransactionAssertLocationV2.fromJson(
          Map<String, dynamic> json) =>
      _$HeliumTransactionAssertLocationV2FromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$HeliumTransactionAssertLocationV2ToJson(this);
}
