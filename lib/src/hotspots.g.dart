// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotspots.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeliumHotspotReward _$HeliumHotspotRewardFromJson(Map<String, dynamic> json) =>
    HeliumHotspotReward(
      account: json['account'] as String,
      amount: json['amount'] as int,
      block: json['block'] as int,
      gateway: json['gateway'] as String,
      hash: json['hash'] as String,
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$HeliumHotspotRewardToJson(
        HeliumHotspotReward instance) =>
    <String, dynamic>{
      'account': instance.account,
      'amount': instance.amount,
      'block': instance.block,
      'gateway': instance.gateway,
      'hash': instance.hash,
      'timestamp': instance.timestamp,
    };

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
      mode: json['mode'] as String,
      status:
          HeliumHotspotStatus.fromJson(json['status'] as Map<String, dynamic>),
      lastPoCChallenge: json['last_poc_challenge'] as int?,
      lastChangeBlock: json['last_change_block'] as int,
      gain: (json['gain'] as num).toDouble(),
      elevation: (json['elevation'] as num).toDouble(),
    );

Map<String, dynamic> _$HeliumHotspotToJson(HeliumHotspot instance) =>
    <String, dynamic>{
      'address': instance.address,
      'block': instance.block,
      'block_added': instance.blockAdded,
      'geocode': instance.geocode,
      'lat': instance.lat,
      'lng': instance.lng,
      'location': instance.location,
      'location_hex': instance.locationHex,
      'name': instance.name,
      'nonce': instance.nonce,
      'speculative_nonce': instance.speculativeNonce,
      'timestamp_added': heliumTimestampToJson(instance.timestampAdded),
      'reward_scale': instance.rewardScale,
      'payer': instance.payer,
      'owner': instance.owner,
      'mode': instance.mode,
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

HeliumGeocode _$HeliumGeocodeFromJson(Map<String, dynamic> json) =>
    HeliumGeocode(
      longCity: json['long_city'] as String?,
      longCountry: json['long_country'] as String?,
      longState: json['long_state'] as String?,
      longStreet: json['long_street'] as String?,
      shortCity: json['short_city'] as String?,
      shortCountry: json['short_country'] as String?,
      shortState: json['short_state'] as String?,
      shortStreet: json['short_street'] as String?,
      cityId: json['city_id'] as String?,
    );

Map<String, dynamic> _$HeliumGeocodeToJson(HeliumGeocode instance) =>
    <String, dynamic>{
      'long_city': instance.longCity,
      'long_country': instance.longCountry,
      'long_state': instance.longState,
      'long_street': instance.longStreet,
      'short_city': instance.shortCity,
      'short_country': instance.shortCountry,
      'short_state': instance.shortState,
      'short_street': instance.shortStreet,
      'city_id': instance.cityId,
    };
