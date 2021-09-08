import 'package:json_annotation/json_annotation.dart';

import 'converters.dart';
import 'shared.dart';

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
class HeliumHotspot {
  /// The B58 address of the hotspot.
  final String address;
  final int block;
  @JsonKey(name: 'block_added')
  final int blockAdded;
  final HeliumGeocode geocode;

  /// The latitude of this hotspot, in degrees.
  /// This is the value from the most recent location assertion transaction.
  final double? lat;

  /// The longitude of this hotspot, in degrees.
  /// This is the value from the most recent location assertion transaction.
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
    toJson: heliumTimestampToJson,
  )
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

  /// The antenna gain in tenths of a dBi.
  /// This is the value from the most recent location assertion transaction.
  final int gain;

  /// The antenna elevation above ground level in metres.
  /// This is the value from the most recent location assertion transaction.
  final int elevation;

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
class HeliumHotspotReward {
  /// The address of the account to which the reward was paid.
  final String account;

  /// The B58 address of the hotspot that earned the reward.
  final String gateway;

  /// The amount of rewards earned, in bones (1 HNT == 100 000 000 bones)
  final int amount;

  /// The block of the transaction containing this reward.
  final int block;

  /// The hash of the mining rewards transaction containing this reward.
  final String hash;

  /// The timestamp of the block containing the rewards transaction.
  @JsonKey(
    fromJson: heliumTimestampFromJson,
    toJson: heliumTimestampToJson,
  )
  final DateTime timestamp;

  HeliumHotspotReward({
    required this.account,
    required this.gateway,
    required this.amount,
    required this.block,
    required this.hash,
    required this.timestamp,
  });

  factory HeliumHotspotReward.fromJson(Map<String, dynamic> json) =>
      _$HeliumHotspotRewardFromJson(json);

  Map<String, dynamic> toJson() => _$HeliumHotspotRewardToJson(this);
}

@JsonSerializable()
class HeliumHotspotRewardTotal {
  /// The sum of rewards earned, in bones (1 HNT == 100 000 000 bones)
  final int sum;

  HeliumHotspotRewardTotal({
    required this.sum,
  });

  factory HeliumHotspotRewardTotal.fromJson(Map<String, dynamic> json) =>
      _$HeliumHotspotRewardTotalFromJson(json);

  Map<String, dynamic> toJson() => _$HeliumHotspotRewardTotalToJson(this);
}
