import 'dart:collection';

import 'package:helium_api_client/src/converters.dart';
import 'package:json_annotation/json_annotation.dart';

import 'shared.dart';

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

  /// The transaction time.
  @JsonKey(fromJson: heliumBlockTimeFromJson, toJson: heliumBlockTimeToJson)
  final DateTime time;

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
    HeliumTransactionType.CONSENSUS_GROUP_V1: (json) =>
        HeliumTransactionConsensusGroupV1.fromJson(json),
    HeliumTransactionType.POC_RECEIPTS_V1: (json) =>
        HeliumTransactionPoCReceiptsV1.fromJson(json),
    HeliumTransactionType.PRICE_ORACLE_V1: (json) =>
        HeliumTransactionPriceOracleV1.fromJson(json),
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
  static const CONSENSUS_GROUP_V1 =
      HeliumTransactionType._internal('consensus_group_v1');
  static const POC_RECEIPTS_V1 =
      HeliumTransactionType._internal('poc_receipts_v1');
  static const PRICE_ORACLE_V1 =
      HeliumTransactionType._internal('price_oracle_v1');
  static const REWARDS_V1 = HeliumTransactionType._internal('rewards_v1');
  static const REWARDS_V2 = HeliumTransactionType._internal('rewards_v2');
  static const TOKEN_BURN_V1 = HeliumTransactionType._internal('token_burn_v1');

  static final Map<String, HeliumTransactionType> _lookup = {
    ADD_GATEWAY_V1.value: ADD_GATEWAY_V1,
    ASSERT_LOCATION_V1.value: ASSERT_LOCATION_V1,
    ASSERT_LOCATION_V2.value: ASSERT_LOCATION_V2,
    CONSENSUS_GROUP_V1.value: CONSENSUS_GROUP_V1,
    POC_RECEIPTS_V1.value: POC_RECEIPTS_V1,
    PRICE_ORACLE_V1.value: PRICE_ORACLE_V1,
    REWARDS_V1.value: REWARDS_V1,
    REWARDS_V2.value: REWARDS_V2,
    TOKEN_BURN_V1.value: TOKEN_BURN_V1,
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
    required DateTime time,
    required this.data,
  }) : super(type: type, hash: hash, height: height, time: time);

  factory HeliumTransactionUnknown.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = HashMap();

    data.addAll(json);

    final type = heliumTransactionTypeFromJson(data.remove('type'));
    final hash = data.remove('hash');
    final height = data.remove('height');
    final time = heliumBlockTimeFromJson(data.remove('time'));

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
    required DateTime time,
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
    required DateTime time,
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
    required DateTime time,
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

@JsonSerializable()
class HeliumTransactionConsensusGroupV1 extends HeliumTransaction {
  final List<String> members;
  final int delay;
  final String proof;

  HeliumTransactionConsensusGroupV1({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required DateTime time,
    required this.members,
    required this.delay,
    required this.proof,
  }) : super(type: type, hash: hash, height: height, time: time);

  factory HeliumTransactionConsensusGroupV1.fromJson(
          Map<String, dynamic> json) =>
      _$HeliumTransactionConsensusGroupV1FromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$HeliumTransactionConsensusGroupV1ToJson(this);
}

@JsonSerializable()
class HeliumTransactionPriceOracleV1 extends HeliumTransaction {
  /// The price of 1 HNT in thousandths of a DC or ten-millionths of a USD.
  final int price;

  /// The Oracle's public key.
  @JsonKey(name: 'public_key')
  final String publicKey;

  /// The block height to report the price.
  @JsonKey(name: 'block_height')
  final int blockHeight;

  // The transaction fee, in DC.
  final int fee;

  HeliumTransactionPriceOracleV1({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required DateTime time,
    required this.price,
    required this.publicKey,
    required this.blockHeight,
    required this.fee,
  }) : super(type: type, hash: hash, height: height, time: time);

  factory HeliumTransactionPriceOracleV1.fromJson(Map<String, dynamic> json) =>
      _$HeliumTransactionPriceOracleV1FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HeliumTransactionPriceOracleV1ToJson(this);
}

@JsonSerializable()
class HeliumTransactionPoCReceiptsV1 extends HeliumTransaction {
  final String challenger;
  @JsonKey(name: 'challenger_owner')
  final String challengerOwner;
  @JsonKey(name: 'challenger_location')
  final String challengerLocation;
  @JsonKey(name: 'challenger_lat')
  final double challengerLat;
  @JsonKey(name: 'challenger_lon')
  final double challengerLon;
  final List<HeliumPoCReceiptsPathElement> path;
  final String secret;
  @JsonKey(name: 'onion_key_hash')
  final String onionKeyHash;
  @JsonKey(name: 'request_block_hash')
  final String? requestBlockHash;
  final int fee;

  HeliumTransactionPoCReceiptsV1({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required DateTime time,
    required this.challenger,
    required this.challengerOwner,
    required this.challengerLocation,
    required this.challengerLat,
    required this.challengerLon,
    required this.path,
    required this.secret,
    required this.onionKeyHash,
    this.requestBlockHash,
    required this.fee,
  }) : super(type: type, hash: hash, height: height, time: time);

  factory HeliumTransactionPoCReceiptsV1.fromJson(Map<String, dynamic> json) =>
      _$HeliumTransactionPoCReceiptsV1FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HeliumTransactionPoCReceiptsV1ToJson(this);
}

@JsonSerializable()
class HeliumPoCReceiptsPathElement {
  final List<HeliumPoCReceiptsWitness> witnesses;
  final HeliumPoCReceiptsReceipt? receipt;
  final HeliumGeocode? geocode;
  final String challengee;
  @JsonKey(name: 'challengee_owner')
  final String challengeeOwner;
  @JsonKey(name: 'challengee_location')
  final String challengeeLocation;
  @JsonKey(name: 'challengee_location_hex')
  final String challengeeLocationHex;
  @JsonKey(name: 'challengee_lat')
  final double challengeeLat;
  @JsonKey(name: 'challengee_lon')
  final double challengeeLon;

  HeliumPoCReceiptsPathElement({
    required this.witnesses,
    this.receipt,
    this.geocode,
    required this.challengee,
    required this.challengeeOwner,
    required this.challengeeLocation,
    required this.challengeeLocationHex,
    required this.challengeeLat,
    required this.challengeeLon,
  });

  factory HeliumPoCReceiptsPathElement.fromJson(Map<String, dynamic> json) =>
      _$HeliumPoCReceiptsPathElementFromJson(json);

  Map<String, dynamic> toJson() => _$HeliumPoCReceiptsPathElementToJson(this);
}

@JsonSerializable()
class HeliumPoCReceiptsWitness {
  final int timestamp;
  final String gateway;
  final String owner;
  final int signal;
  final double? snr;
  final String location;
  @JsonKey(name: 'location_hex')
  final String locationHex;
  @JsonKey(name: 'packet_hash')
  final String packetHash;
  @JsonKey(name: 'is_valid')
  final bool? isValid;
  @JsonKey(name: 'invalid_reason')
  final String? invalidReason;
  final double? frequency;
  final String? datarate;
  final int? channel;

  HeliumPoCReceiptsWitness({
    required this.timestamp,
    required this.gateway,
    required this.owner,
    required this.signal,
    this.snr,
    required this.location,
    required this.locationHex,
    required this.packetHash,
    this.isValid,
    this.invalidReason,
    this.frequency,
    this.datarate,
    this.channel,
  });

  factory HeliumPoCReceiptsWitness.fromJson(Map<String, dynamic> json) =>
      _$HeliumPoCReceiptsWitnessFromJson(json);

  Map<String, dynamic> toJson() => _$HeliumPoCReceiptsWitnessToJson(this);
}

@JsonSerializable()
class HeliumPoCReceiptsReceipt {
  final int timestamp;
  final String gateway;
  final int signal;
  final String origin;
  final String data;

  HeliumPoCReceiptsReceipt({
    required this.timestamp,
    required this.gateway,
    required this.signal,
    required this.origin,
    required this.data,
  });

  factory HeliumPoCReceiptsReceipt.fromJson(Map<String, dynamic> json) =>
      _$HeliumPoCReceiptsReceiptFromJson(json);

  Map<String, dynamic> toJson() => _$HeliumPoCReceiptsReceiptToJson(this);
}
