import 'dart:collection';

import 'package:helium_api_client/src/converters.dart';
import 'package:json_annotation/json_annotation.dart';

import 'shared.dart';

part 'transactions.g.dart';

/// A transaction on the Helium blockchain.
///
/// This class is never instantiated directly; instead, it absctracts the
/// common fields across all transactions. It also provides support for
/// deserializing transactions from JSON by dispatching to the appropriate
/// sub-class based on the type of the transaction, see
/// [HeliumTransaction.fromJson].
abstract class HeliumTransaction {
  /// The type of transaction.
  @JsonKey(
    toJson: _heliumTransactionTypeToJson,
    fromJson: _heliumTransactionTypeFromJson,
  )
  final HeliumTransactionType type;

  /// The transaction hash.
  final String hash;

  /// The block containing the transaction.
  final int height;

  /// The transaction time.
  @JsonKey(fromJson: heliumBlockTimeFromJson, toJson: heliumBlockTimeToJson)
  final DateTime time;

  /// Creates a new instance.
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

  /// Creates an instance from a map derived from the JSON serialization.
  ///
  /// Returns the appropriate subclass based on the type field. If the
  /// transaction type is not recognized, returns an instance of
  /// [HeliumTransactionUnknown].
  factory HeliumTransaction.fromJson(Map<String, dynamic> json) {
    final type = HeliumTransactionType.get(json['type']);
    final deserializer = _deserializerMap[type];

    if (deserializer == null) {
      return HeliumTransactionUnknown.fromJson(json);
    }

    return deserializer(json);
  }

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson();
}

/// An enumeration of transaction types.
///
/// To prevent this library from throwing an error when a new transaction
/// type is encountered, this enumeration is open-ended so that additional
/// values can be created at run time. When processing a transaction with
/// a transaction type created at run time, this library represents the
/// transaction with an instance of [HeliumTransactionUnknown].
class HeliumTransactionType {
  /// The value indicating the transaction type, as it is represented in
  /// JSON by the Helium API.
  final String value;

  const HeliumTransactionType._internal(this.value);

  /// Given a transaction type from JSON, return the enumerated value.
  ///
  /// If the mode is not recognized, a new enumerated value is constructed
  /// and that is returned.
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

  /// add_gateway_v1
  static const ADD_GATEWAY_V1 =
      HeliumTransactionType._internal('add_gateway_v1');

  /// assert_location_v1
  static const ASSERT_LOCATION_V1 =
      HeliumTransactionType._internal('assert_location_v1');

  /// assert_location_v2
  static const ASSERT_LOCATION_V2 =
      HeliumTransactionType._internal('assert_location_v2');

  /// consensus_group_v1
  static const CONSENSUS_GROUP_V1 =
      HeliumTransactionType._internal('consensus_group_v1');

  /// poc_receipts_v1
  static const POC_RECEIPTS_V1 =
      HeliumTransactionType._internal('poc_receipts_v1');

  /// price_oracle_v1
  static const PRICE_ORACLE_V1 =
      HeliumTransactionType._internal('price_oracle_v1');

  /// rewards_v1
  static const REWARDS_V1 = HeliumTransactionType._internal('rewards_v1');

  /// rewards_v2
  static const REWARDS_V2 = HeliumTransactionType._internal('rewards_v2');

  /// token_burn_v1
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

/// A private method that can be referenced from @JsonKey()
HeliumTransactionType _heliumTransactionTypeFromJson(String value) {
  return HeliumTransactionType.get(value);
}

/// A private method that can be referenced from @JsonKey()
String _heliumTransactionTypeToJson(HeliumTransactionType type) {
  return type.value;
}

/// Represents a transaction of an unknown type.
///
/// Not all documented transaction types have been implemented by this library,
/// and even when this library does implement all documented transaction types,
/// new ones can be added to the blockchain. This library won't throw an
/// error when it encounters an unknown transaction type; instead, it returns
/// an instance of this class.
class HeliumTransactionUnknown extends HeliumTransaction {
  /// The other fields in the transaction record.
  final Map<String, dynamic> data;

  /// Creates a new instance.
  HeliumTransactionUnknown({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required DateTime time,
    required this.data,
  }) : super(type: type, hash: hash, height: height, time: time);

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumTransactionUnknown.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = HashMap();

    data.addAll(json);

    final type = _heliumTransactionTypeFromJson(data.remove('type'));
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

  /// Creates a map suitable for serialization to JSON.
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

/// The add_gateway_v1 transaction.
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

  /// Creates a new instance.
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

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumTransactionAddGatewayV1.fromJson(Map<String, dynamic> json) =>
      _$HeliumTransactionAddGatewayV1FromJson(json);

  /// Creates a map suitable for serialization to JSON.
  @override
  Map<String, dynamic> toJson() => _$HeliumTransactionAddGatewayV1ToJson(this);
}

/// The assert_location_v1 transaction.
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

  /// Creates a new instance.
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

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumTransactionAssertLocationV1.fromJson(
          Map<String, dynamic> json) =>
      _$HeliumTransactionAssertLocationV1FromJson(json);

  /// Creates a map suitable for serialization to JSON.
  @override
  Map<String, dynamic> toJson() =>
      _$HeliumTransactionAssertLocationV1ToJson(this);
}

/// The assert_location_v2 transaction.
@JsonSerializable()
class HeliumTransactionAssertLocationV2
    extends HeliumTransactionAssertLocationV1 {
  /// The antenna elevation above ground level in metres.
  final int elevation;

  /// The antenna gain in tenths of a dBi.
  final int gain;

  /// Creates a new instance.
  HeliumTransactionAssertLocationV2({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required DateTime time,
    required int fee,
    required int stakingFee,
    required String gateway,
    required String owner,
    required String payer,
    required String location,
    required double lat,
    required double lng,
    required int nonce,
    required this.elevation,
    required this.gain,
  }) : super(
          type: type,
          hash: hash,
          height: height,
          time: time,
          fee: fee,
          stakingFee: stakingFee,
          gateway: gateway,
          owner: owner,
          payer: payer,
          location: location,
          lat: lat,
          lng: lng,
          nonce: nonce,
        );

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumTransactionAssertLocationV2.fromJson(
          Map<String, dynamic> json) =>
      _$HeliumTransactionAssertLocationV2FromJson(json);

  /// Creates a map suitable for serialization to JSON.
  @override
  Map<String, dynamic> toJson() =>
      _$HeliumTransactionAssertLocationV2ToJson(this);
}

/// The consensus_group_v1 transaction.
@JsonSerializable()
class HeliumTransactionConsensusGroupV1 extends HeliumTransaction {
  final List<String> members;
  final int delay;
  final String proof;

  /// Creates a new instance.
  HeliumTransactionConsensusGroupV1({
    required HeliumTransactionType type,
    required String hash,
    required int height,
    required DateTime time,
    required this.members,
    required this.delay,
    required this.proof,
  }) : super(type: type, hash: hash, height: height, time: time);

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumTransactionConsensusGroupV1.fromJson(
          Map<String, dynamic> json) =>
      _$HeliumTransactionConsensusGroupV1FromJson(json);

  /// Creates a map suitable for serialization to JSON.
  @override
  Map<String, dynamic> toJson() =>
      _$HeliumTransactionConsensusGroupV1ToJson(this);
}

/// The price_oracle_v1 transaction.
@JsonSerializable()
class HeliumTransactionPriceOracleV1 extends HeliumTransaction {
  /// The price of 1 HNT in thousandths of a DC or hundred-millionths of a USD.
  final int price;

  /// The Oracle's public key.
  @JsonKey(name: 'public_key')
  final String publicKey;

  /// The block height to report the price.
  @JsonKey(name: 'block_height')
  final int blockHeight;

  /// The transaction fee, in DC.
  final int fee;

  /// Creates a new instance.
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

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumTransactionPriceOracleV1.fromJson(Map<String, dynamic> json) =>
      _$HeliumTransactionPriceOracleV1FromJson(json);

  /// Creates a map suitable for serialization to JSON.
  @override
  Map<String, dynamic> toJson() => _$HeliumTransactionPriceOracleV1ToJson(this);
}

/// The poc_receipts_v1 transaction.
@JsonSerializable()
class HeliumTransactionPoCReceiptsV1 extends HeliumTransaction {
  /// The B58 address of the hotspot that created the challenge.
  final String challenger;

  /// The wallet address of the owner of the hotspot that created the challenge.
  @JsonKey(name: 'challenger_owner')
  final String challengerOwner;

  /// The H3 index of the res 12 hex of the hotspot that created the challenge.
  ///
  /// H3 resolution 12 has hexagon sides ~9.42 metres long.
  @JsonKey(name: 'challenger_location')
  final String challengerLocation;

  /// The latitude of the hotspot that created the challenge, in degrees.
  @JsonKey(name: 'challenger_lat')
  final double challengerLat;

  /// The latitude of the hotspot that created the challenge, in degrees.
  @JsonKey(name: 'challenger_lon')
  final double challengerLon;

  /// The Proof of Coverage path.
  ///
  /// Proof of Coverage transactions after HIP 15 took effect only have one
  /// element in their path. Transactions prior to HIP 15 may have more than
  /// one.
  final List<HeliumPoCPathElement> path;

  final String secret;

  /// The [onionKeyHash] of the PoC challenge transaction.
  @JsonKey(name: 'onion_key_hash')
  final String onionKeyHash;

  /// The block containing the transaction that created the PoC challenge.
  @JsonKey(name: 'request_block_hash')
  final String? requestBlockHash;

  /// The transaction fee, in DC.
  final int fee;

  /// Creates a new instance.
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

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumTransactionPoCReceiptsV1.fromJson(Map<String, dynamic> json) =>
      _$HeliumTransactionPoCReceiptsV1FromJson(json);

  /// Creates a map suitable for serialization to JSON.
  @override
  Map<String, dynamic> toJson() => _$HeliumTransactionPoCReceiptsV1ToJson(this);
}

/// Represents an element of a Proof of Coverage path. It is part of a
/// poc_receipts_v1 transaction.
@JsonSerializable()
class HeliumPoCPathElement {
  /// The hotspots that witnessed the beacon.
  final List<HeliumPoCWitness> witnesses;
  final HeliumPoCReceipt? receipt;

  /// The reverse geocode of the hotspot that sent the beacon.
  final HeliumGeocode? geocode;

  /// The B58 address of the hotspot that sent the beacon.
  final String challengee;

  /// The wallet address of the owner of the hotspot that sent the beacon.
  @JsonKey(name: 'challengee_owner')
  final String challengeeOwner;

  /// The H3 index of the res 12 hex of the hotspot that sent the beacon.
  ///
  /// H3 resolution 12 has hexagon sides ~9.42 metres long.
  @JsonKey(name: 'challengee_location')
  final String challengeeLocation;

  /// The H3 index of the res 8 hex of the hotspot that sent the beacon.
  ///
  /// H3 resolution 8 has hexagon sides ~461.35 metres long.
  @JsonKey(name: 'challengee_location_hex')
  final String challengeeLocationHex;

  /// The latitude of the hotspot that sent the beacon, in degrees.
  @JsonKey(name: 'challengee_lat')
  final double challengeeLat;

  /// The longitude of the hotspot that sent the beacon, in degrees.
  @JsonKey(name: 'challengee_lon')
  final double challengeeLon;

  /// Creates a new instance.
  HeliumPoCPathElement({
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

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumPoCPathElement.fromJson(Map<String, dynamic> json) =>
      _$HeliumPoCPathElementFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumPoCPathElementToJson(this);
}

/// Represents the witnesses of the Proof of Coverage beacon. It is part of a
/// poc_receipts_v1 transaction.
@JsonSerializable()
class HeliumPoCWitness {
  final int timestamp;

  /// The B58 address of the hotspot that witnessed the beacon.
  final String gateway;

  /// The wallet address of the owner of the witness.
  final String owner;

  /// The signal strength in dBm.
  final int signal;

  /// The signal to noise ratio in dB.
  final double? snr;

  /// The H3 index of the res 12 hex of the witness.
  ///
  /// H3 resolution 12 has hexagon sides ~9.42 metres long.
  final String location;

  /// The H3 index of the res 8 hex of the witness.
  ///
  /// H3 resolution 8 has hexagon sides ~461.35 metres long.
  @JsonKey(name: 'location_hex')
  final String locationHex;

  @JsonKey(name: 'packet_hash')
  final String packetHash;

  /// True if the witnessed signal is valid; false otherwise.
  @JsonKey(name: 'is_valid')
  final bool? isValid;

  /// Text describing why the witnessed signal is invalid; null if it
  /// was valid.
  ///
  /// Possible reasons include:
  ///
  /// * witness_not_same_region
  /// * witness_too_far
  /// * witness_rssi_too_high
  /// * witness_on_incorrect_channel
  /// * witness_rssi_below_lower_bound
  /// * insufficient_data
  /// * incorrect_frequency
  /// * witness_too_close
  /// * pentagonal_distortion
  ///
  /// See: https://github.com/helium/blockchain-core/blob/master/src/transactions/v1/blockchain_txn_poc_receipts_v1.erl
  @JsonKey(name: 'invalid_reason')
  final String? invalidReason;

  /// The frequency of the received signal, in MHz.
  final double? frequency;

  /// The data rate at which the signal was received.
  final String? datarate;

  /// The channel on which the signal was received.
  final int? channel;

  /// Creates a new instance.
  HeliumPoCWitness({
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

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumPoCWitness.fromJson(Map<String, dynamic> json) =>
      _$HeliumPoCWitnessFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumPoCWitnessToJson(this);
}

/// This is part of a poc_receipts_v1 transaction.
@JsonSerializable()
class HeliumPoCReceipt {
  final int timestamp;

  /// The B58 address of the hotspot that sent the beacon.
  final String gateway;
  final int signal;
  final String origin;
  final String data;

  /// Creates a new instance.
  HeliumPoCReceipt({
    required this.timestamp,
    required this.gateway,
    required this.signal,
    required this.origin,
    required this.data,
  });

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumPoCReceipt.fromJson(Map<String, dynamic> json) =>
      _$HeliumPoCReceiptFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumPoCReceiptToJson(this);
}
