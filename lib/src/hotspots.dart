import 'package:json_annotation/json_annotation.dart';

import 'converters.dart';

part 'hotspots.g.dart';

class HeliumHotspotFilterMode {
  final String value;
  const HeliumHotspotFilterMode._internal(this.value);

  @override
  String toString() => 'HeliumHotspotFilterMode.$value';

  static const DATA_ONLY = HeliumHotspotFilterMode._internal('dataonly');
  static const FULL = HeliumHotspotFilterMode._internal('full');
  static const LIGHT = HeliumHotspotFilterMode._internal('light');
}

@JsonSerializable()
class HeliumHotspotReward {
  final String account;
  final int amount;
  final int block;
  final String gateway;
  final String hash;
  final String timestamp;

  HeliumHotspotReward({
    required this.account,
    required this.amount,
    required this.block,
    required this.gateway,
    required this.hash,
    required this.timestamp,
  });

  factory HeliumHotspotReward.fromJson(Map<String, dynamic> json) =>
      _$HeliumHotspotRewardFromJson(json);
  Map<String, dynamic> toJson() => _$HeliumHotspotRewardToJson(this);
}

@JsonSerializable()
class HeliumHotspot {
  final String address;
  final int block;
  @JsonKey(name: 'block_added')
  final int blockAdded;
  final HeliumGeocode geocode;
  final double? lat;
  final double? lng;
  final String? location;
  @JsonKey(name: 'location_hex')
  final String? locationHex;
  final String name;
  final int nonce;

  /// [speculativeNonce] can sometimes be a double due to a bug in the Helium
  /// API in which the distance of a hotspot from a searched location is
  /// reported in [speculativeNonce] instead of its own field.
  @JsonKey(name: 'speculative_nonce')
  final num? speculativeNonce;
  @JsonKey(
      name: 'timestamp_added',
      fromJson: heliumTimestampFromJson,
      toJson: heliumTimestampToJson)
  final DateTime timestampAdded;
  @JsonKey(name: 'reward_scale')
  final double? rewardScale;
  final String? payer;
  final String owner;
  final String mode;
  final HeliumHotspotStatus status;
  @JsonKey(name: 'last_poc_challenge')
  final int? lastPoCChallenge;
  @JsonKey(name: 'last_change_block')
  final int lastChangeBlock;
  final double
      gain; // TODO: add a custom deserializer to convert from tenths of dBi to dBi
  final double elevation;

  HeliumHotspot({
    required this.address,
    required this.block,
    required this.blockAdded,
    required this.geocode,
    this.lat,
    this.lng,
    this.location,
    this.locationHex,
    required this.name,
    required this.nonce,
    this.speculativeNonce,
    required this.timestampAdded,
    this.rewardScale,
    required this.payer,
    required this.owner,
    required this.mode,
    required this.status,
    this.lastPoCChallenge,
    required this.lastChangeBlock,
    required this.gain,
    required this.elevation,
  });

  factory HeliumHotspot.fromJson(Map<String, dynamic> json) =>
      _$HeliumHotspotFromJson(json);
  Map<String, dynamic> toJson() => _$HeliumHotspotToJson(this);
}

@JsonSerializable()
class HeliumHotspotStatus {
  final int? height;
  final String online;
  final String? timestamp;
  @JsonKey(name: 'listen_addrs')
  final List<String>? listenAddresses;

  HeliumHotspotStatus({
    this.height,
    required this.online,
    this.timestamp,
    this.listenAddresses,
  });

  factory HeliumHotspotStatus.fromJson(Map<String, dynamic> json) =>
      _$HeliumHotspotStatusFromJson(json);
  Map<String, dynamic> toJson() => _$HeliumHotspotStatusToJson(this);
}

@JsonSerializable()
class HeliumGeocode {
  @JsonKey(name: 'long_city')
  final String? longCity;
  @JsonKey(name: 'long_country')
  final String? longCountry;
  @JsonKey(name: 'long_state')
  final String? longState;
  @JsonKey(name: 'long_street')
  final String? longStreet;
  @JsonKey(name: 'short_city')
  final String? shortCity;
  @JsonKey(name: 'short_country')
  final String? shortCountry;
  @JsonKey(name: 'short_state')
  final String? shortState;
  @JsonKey(name: 'short_street')
  final String? shortStreet;
  @JsonKey(name: 'city_id')
  final String? cityId;

  HeliumGeocode({
    this.longCity,
    this.longCountry,
    this.longState,
    this.longStreet,
    this.shortCity,
    this.shortCountry,
    this.shortState,
    this.shortStreet,
    this.cityId,
  });

  factory HeliumGeocode.fromJson(Map<String, dynamic> json) =>
      _$HeliumGeocodeFromJson(json);
  Map<String, dynamic> toJson() => _$HeliumGeocodeToJson(this);
}
