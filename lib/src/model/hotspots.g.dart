// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotspots.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeliumHotspot _$HeliumHotspotFromJson(Map<String, dynamic> json) =>
    HeliumHotspot(
      address: json['address'] as String,
      block: json['block'] as int,
      blockAdded: json['block_added'] as int,
      geocode: HeliumGeocode.fromJson(json['geocode'] as Map<String, dynamic>),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      location: json['location'] as String?,
      locationHex: json['location_hex'] as String?,
      name: json['name'] as String,
      nonce: json['nonce'] as int,
      speculativeNonce: json['speculative_nonce'] as num?,
      timestampAdded:
          heliumTimestampFromJson(json['timestamp_added'] as String),
      rewardScale: (json['reward_scale'] as num?)?.toDouble(),
      payer: json['payer'] as String?,
      owner: json['owner'] as String,
      mode: _heliumHotspotModeFromJson(json['mode'] as String),
      status:
          HeliumHotspotStatus.fromJson(json['status'] as Map<String, dynamic>),
      lastPoCChallenge: json['last_poc_challenge'] as int?,
      lastChangeBlock: json['last_change_block'] as int,
      gain: json['gain'] as int,
      elevation: json['elevation'] as int,
    );

Map<String, dynamic> _$HeliumHotspotToJson(HeliumHotspot instance) =>
    <String, dynamic>{
      'address': instance.address,
      'block': instance.block,
      'block_added': instance.blockAdded,
      'timestamp_added': heliumTimestampToJson(instance.timestampAdded),
      'lat': instance.lat,
      'lng': instance.lng,
      'location': instance.location,
      'location_hex': instance.locationHex,
      'geocode': instance.geocode,
      'name': instance.name,
      'nonce': instance.nonce,
      'speculative_nonce': instance.speculativeNonce,
      'reward_scale': instance.rewardScale,
      'payer': instance.payer,
      'owner': instance.owner,
      'mode': _heliumHotspotModeToJson(instance.mode),
      'status': instance.status,
      'last_poc_challenge': instance.lastPoCChallenge,
      'last_change_block': instance.lastChangeBlock,
      'gain': instance.gain,
      'elevation': instance.elevation,
    };

HeliumHotspotStatus _$HeliumHotspotStatusFromJson(Map<String, dynamic> json) =>
    HeliumHotspotStatus(
      height: json['height'] as int?,
      online: json['online'] as String,
      timestamp: json['timestamp'] as String?,
      listenAddresses: (json['listen_addrs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$HeliumHotspotStatusToJson(
        HeliumHotspotStatus instance) =>
    <String, dynamic>{
      'height': instance.height,
      'online': instance.online,
      'timestamp': instance.timestamp,
      'listen_addrs': instance.listenAddresses,
    };

HeliumHotspotReward _$HeliumHotspotRewardFromJson(Map<String, dynamic> json) =>
    HeliumHotspotReward(
      account: json['account'] as String,
      gateway: json['gateway'] as String,
      amount: json['amount'] as int,
      block: json['block'] as int,
      hash: json['hash'] as String,
      timestamp: heliumTimestampFromJson(json['timestamp'] as String),
    );

Map<String, dynamic> _$HeliumHotspotRewardToJson(
        HeliumHotspotReward instance) =>
    <String, dynamic>{
      'account': instance.account,
      'gateway': instance.gateway,
      'amount': instance.amount,
      'block': instance.block,
      'hash': instance.hash,
      'timestamp': heliumTimestampToJson(instance.timestamp),
    };

HeliumHotspotRewardTotal _$HeliumHotspotRewardTotalFromJson(
        Map<String, dynamic> json) =>
    HeliumHotspotRewardTotal(
      sum: json['sum'] as int,
    );

Map<String, dynamic> _$HeliumHotspotRewardTotalToJson(
        HeliumHotspotRewardTotal instance) =>
    <String, dynamic>{
      'sum': instance.sum,
    };
