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
      time: heliumBlockTimeFromJson(json['time'] as int),
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
      'time': heliumBlockTimeToJson(instance.time),
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
      time: heliumBlockTimeFromJson(json['time'] as int),
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
      'time': heliumBlockTimeToJson(instance.time),
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
      time: heliumBlockTimeFromJson(json['time'] as int),
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
      'time': heliumBlockTimeToJson(instance.time),
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

HeliumTransactionConsensusGroupV1 _$HeliumTransactionConsensusGroupV1FromJson(
        Map<String, dynamic> json) =>
    HeliumTransactionConsensusGroupV1(
      type: heliumTransactionTypeFromJson(json['type'] as String),
      hash: json['hash'] as String,
      height: json['height'] as int,
      time: heliumBlockTimeFromJson(json['time'] as int),
      members:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
      delay: json['delay'] as int,
      proof: json['proof'] as String,
    );

Map<String, dynamic> _$HeliumTransactionConsensusGroupV1ToJson(
        HeliumTransactionConsensusGroupV1 instance) =>
    <String, dynamic>{
      'type': heliumTransactionTypeToJson(instance.type),
      'hash': instance.hash,
      'height': instance.height,
      'time': heliumBlockTimeToJson(instance.time),
      'members': instance.members,
      'delay': instance.delay,
      'proof': instance.proof,
    };

HeliumTransactionPoCReceiptsV1 _$HeliumTransactionPoCReceiptsV1FromJson(
        Map<String, dynamic> json) =>
    HeliumTransactionPoCReceiptsV1(
      type: heliumTransactionTypeFromJson(json['type'] as String),
      hash: json['hash'] as String,
      height: json['height'] as int,
      time: heliumBlockTimeFromJson(json['time'] as int),
      challenger: json['challenger'] as String,
      challengerOwner: json['challenger_owner'] as String,
      challengerLocation: json['challenger_location'] as String,
      challengerLat: (json['challenger_lat'] as num).toDouble(),
      challengerLon: (json['challenger_lon'] as num).toDouble(),
      path: (json['path'] as List<dynamic>)
          .map((e) =>
              HeliumPoCReceiptsPathElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      secret: json['secret'] as String,
      onionKeyHash: json['onion_key_hash'] as String,
      requestBlockHash: json['request_block_hash'] as String?,
      fee: json['fee'] as int,
    );

Map<String, dynamic> _$HeliumTransactionPoCReceiptsV1ToJson(
        HeliumTransactionPoCReceiptsV1 instance) =>
    <String, dynamic>{
      'type': heliumTransactionTypeToJson(instance.type),
      'hash': instance.hash,
      'height': instance.height,
      'time': heliumBlockTimeToJson(instance.time),
      'challenger': instance.challenger,
      'challenger_owner': instance.challengerOwner,
      'challenger_location': instance.challengerLocation,
      'challenger_lat': instance.challengerLat,
      'challenger_lon': instance.challengerLon,
      'path': instance.path,
      'secret': instance.secret,
      'onion_key_hash': instance.onionKeyHash,
      'request_block_hash': instance.requestBlockHash,
      'fee': instance.fee,
    };

HeliumPoCReceiptsPathElement _$HeliumPoCReceiptsPathElementFromJson(
        Map<String, dynamic> json) =>
    HeliumPoCReceiptsPathElement(
      witnesses: (json['witnesses'] as List<dynamic>)
          .map((e) =>
              HeliumPoCReceiptsWitness.fromJson(e as Map<String, dynamic>))
          .toList(),
      receipt: json['receipt'] == null
          ? null
          : HeliumPoCReceiptsReceipt.fromJson(
              json['receipt'] as Map<String, dynamic>),
      geocode: json['geocode'] == null
          ? null
          : HeliumGeocode.fromJson(json['geocode'] as Map<String, dynamic>),
      challengee: json['challengee'] as String,
      challengeeOwner: json['challengee_owner'] as String,
      challengeeLocation: json['challengee_location'] as String,
      challengeeLocationHex: json['challengee_location_hex'] as String,
      challengeeLat: (json['challengee_lat'] as num).toDouble(),
      challengeeLon: (json['challengee_lon'] as num).toDouble(),
    );

Map<String, dynamic> _$HeliumPoCReceiptsPathElementToJson(
        HeliumPoCReceiptsPathElement instance) =>
    <String, dynamic>{
      'witnesses': instance.witnesses,
      'receipt': instance.receipt,
      'geocode': instance.geocode,
      'challengee': instance.challengee,
      'challengee_owner': instance.challengeeOwner,
      'challengee_location': instance.challengeeLocation,
      'challengee_location_hex': instance.challengeeLocationHex,
      'challengee_lat': instance.challengeeLat,
      'challengee_lon': instance.challengeeLon,
    };

HeliumPoCReceiptsWitness _$HeliumPoCReceiptsWitnessFromJson(
        Map<String, dynamic> json) =>
    HeliumPoCReceiptsWitness(
      timestamp: json['timestamp'] as int,
      gateway: json['gateway'] as String,
      owner: json['owner'] as String,
      signal: json['signal'] as int,
      snr: (json['snr'] as num?)?.toDouble(),
      location: json['location'] as String,
      locationHex: json['location_hex'] as String,
      packetHash: json['packet_hash'] as String,
      isValid: json['is_valid'] as bool?,
      invalidReason: json['invalid_reason'] as String?,
      frequency: (json['frequency'] as num?)?.toDouble(),
      datarate: json['datarate'] as String?,
      channel: json['channel'] as int?,
    );

Map<String, dynamic> _$HeliumPoCReceiptsWitnessToJson(
        HeliumPoCReceiptsWitness instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'gateway': instance.gateway,
      'owner': instance.owner,
      'signal': instance.signal,
      'snr': instance.snr,
      'location': instance.location,
      'location_hex': instance.locationHex,
      'packet_hash': instance.packetHash,
      'is_valid': instance.isValid,
      'invalid_reason': instance.invalidReason,
      'frequency': instance.frequency,
      'datarate': instance.datarate,
      'channel': instance.channel,
    };

HeliumPoCReceiptsReceipt _$HeliumPoCReceiptsReceiptFromJson(
        Map<String, dynamic> json) =>
    HeliumPoCReceiptsReceipt(
      timestamp: json['timestamp'] as int,
      gateway: json['gateway'] as String,
      signal: json['signal'] as int,
      origin: json['origin'] as String,
      data: json['data'] as String,
    );

Map<String, dynamic> _$HeliumPoCReceiptsReceiptToJson(
        HeliumPoCReceiptsReceipt instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'gateway': instance.gateway,
      'signal': instance.signal,
      'origin': instance.origin,
      'data': instance.data,
    };
