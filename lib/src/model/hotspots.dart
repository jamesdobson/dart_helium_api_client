import 'package:helium_api_client/src/common.dart';
import 'package:helium_api_client/src/converters.dart';
import 'package:json_annotation/json_annotation.dart';

import 'shared.dart';

part 'hotspots.g.dart';

/// Detailed hotspot information.
///
/// This information is derived by the Helium API from a combination of
/// blockchain transactions and P2P data. For example, the information about
/// the hotspot's location is derived from assert_location_v1 and _v2
/// transactions, and the [payer] and [blockAdded] are derived from the
/// add_gateway_v1 transaction. On the other hand, [status] is derived from
/// P2P queries.
@JsonSerializable()
class HeliumHotspot {
  /// The B58 address of the hotspot.
  final String address;

  /// This seems to be the highest block known to the API; doesn't seem to
  /// have any relationship to the hotspot itself.
  final int block;

  /// The block where this hotspot was added to the blockchain.
  @JsonKey(name: 'block_added')
  final int blockAdded;

  /// The time of the block in [blockAdded].
  @JsonKey(
    name: 'timestamp_added',
    fromJson: heliumTimestampFromJson,
    toJson: heliumTimestampToJson,
  )
  final DateTime timestampAdded;

  /// The latitude of this hotspot, in degrees.
  /// This is the value from the most recent location assertion transaction.
  final double? lat;

  /// The longitude of this hotspot, in degrees.
  /// This is the value from the most recent location assertion transaction.
  final double? lng;

  /// The H3 index of the res 12 hex where the hotspot is located.
  ///
  /// H3 resolution 12 has hexagon sides ~9.42 metres long.
  final String? location;

  /// The H3 index of the res 8 hex where the hotspot is located.
  ///
  /// H3 resolution 8 has hexagon sides ~461.35 metres long.
  @JsonKey(name: 'location_hex')
  final String? locationHex;

  /// The reverse geocode of the hotspot's location.
  final HeliumGeocode geocode;

  /// The name 3-word animal name of the hotspot
  ///
  /// The name is all lower-case with dashes between the words, e.g.
  /// 'tall-plum-griffin'. Because of collisions in the Angry Purple Tiger
  /// algorithm, more than one hotspot may have the same name.
  final String name;

  final int nonce;

  /// The speculative nonce, only filled out when a single hotspot is requested
  /// by address.
  ///
  /// [speculativeNonce] can sometimes be a double due to a bug in the Helium
  /// API in which the distance of a hotspot from a searched location is
  /// reported in [speculativeNonce] instead of its own field.
  @JsonKey(name: 'speculative_nonce')
  final num? speculativeNonce;

  /// The hotspot's PoC transmission reward scale.
  ///
  /// See HIP17 for more information.
  @JsonKey(name: 'reward_scale')
  final double? rewardScale;

  /// The wallet address that paid for the transaction that added this hotspot
  /// to the blockchain.
  final String? payer;

  /// The wallet address of the hotspot's owner.
  final String owner;

  /// The type of hotspot.
  @JsonKey(
    toJson: _heliumHotspotModeToJson,
    fromJson: _heliumHotspotModeFromJson,
  )
  final HeliumHotspotMode mode;

  /// Operational status of this hotspot.
  ///
  /// Hotspot status is computed periodically by the API server by making
  /// queries to the P2P network.
  final HeliumHotspotStatus status;

  /// The block where this hotspot last issued a proof-of-coverage challenge.
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

  /// Creates a new instance.
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

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumHotspot.fromJson(Map<String, dynamic> json) =>
      _$HeliumHotspotFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumHotspotToJson(this);
}

/// An enumeration of the mode in which a hotspot operates.
class HeliumHotspotMode {
  /// The value indicating the mode, as it is represented in JSON by the
  /// Helium API.
  final String value;

  const HeliumHotspotMode._internal(this.value);

  @override
  String toString() => 'HeliumHotspotFilterMode.$value';

  /// Given a hotspot mode from JSON, return the enumerated value.
  ///
  /// Throws [HeliumException] if the mode is not recognized.
  static HeliumHotspotMode parse(String s) {
    final mode = _lookup[s];

    if (mode != null) {
      return mode;
    }

    throw HeliumException('Unknown hotspot mode "$s"');
  }

  /// Data Only hotspots use Validators to get information about the Helium
  /// blockchain and get rewarded for forwarding Data Packets.
  static const DATA_ONLY = HeliumHotspotMode._internal('dataonly');

  /// Full hotspots maintain a full copy of the Helium blockchain, participate
  /// in Proof of Coverage rewards, and get rewarded for forwarding Data
  /// Packets.
  static const FULL = HeliumHotspotMode._internal('full');

  /// Light hotspots use Validators to get information about the Helium
  /// blockchain, participate in Proof of Coverage rewards, and get rewarded
  /// for forwarding Data Packets.
  static const LIGHT = HeliumHotspotMode._internal('light');

  static const Map<String, HeliumHotspotMode> _lookup = {
    'dataonly': DATA_ONLY,
    'full': FULL,
    'light': LIGHT,
  };
}

/// A private method that can be referenced from @JsonKey()
HeliumHotspotMode _heliumHotspotModeFromJson(String json) {
  return HeliumHotspotMode.parse(json);
}

/// A private method that can be referenced from @JsonKey()
String _heliumHotspotModeToJson(HeliumHotspotMode mode) {
  return mode.value;
}

/// The status of a hotspot.
///
/// Objects from this class are only ever seen in the context of a
/// [HeliumHotspot], they are not constructed independently.
@JsonSerializable()
class HeliumHotspotStatus {
  /// The highest block synced by the hotspot when this status update was
  /// obtained.
  final int? height;

  /// Indicates if the hotspot is online.
  ///
  /// If the hotspot is online, the value is 'online'.
  final String online;

  /// The timestamp of this status update.
  final String? timestamp;

  /// Internet addresses where the hotspot is listening.
  /// e.g. '/ip4/www.xxx.yyy.zzz/tcp/44158'
  @JsonKey(name: 'listen_addrs')
  final List<String>? listenAddresses;

  /// Creates a new instance.
  HeliumHotspotStatus({
    this.height,
    required this.online,
    this.timestamp,
    this.listenAddresses,
  });

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumHotspotStatus.fromJson(Map<String, dynamic> json) =>
      _$HeliumHotspotStatusFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumHotspotStatusToJson(this);
}

/// A reward earned by a hotspot as it mines HNT by participating in Proof of
/// Coverage and forwards Data Packets.
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

  /// Creates a new instance.
  HeliumHotspotReward({
    required this.account,
    required this.gateway,
    required this.amount,
    required this.block,
    required this.hash,
    required this.timestamp,
  });

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumHotspotReward.fromJson(Map<String, dynamic> json) =>
      _$HeliumHotspotRewardFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumHotspotRewardToJson(this);
}

/// A sum of the rewards earned by a hotspot from participating in
/// multiple Proof of Coverage transactions and forwarding Data Packets.
@JsonSerializable()
class HeliumHotspotRewardTotal {
  /// The sum of rewards earned, in bones (1 HNT == 100 000 000 bones)
  final int sum;

  /// Creates a new instance.
  HeliumHotspotRewardTotal({
    required this.sum,
  });

  /// Creates an instance from a map derived from the JSON serialization.
  factory HeliumHotspotRewardTotal.fromJson(Map<String, dynamic> json) =>
      _$HeliumHotspotRewardTotalFromJson(json);

  /// Creates a map suitable for serialization to JSON.
  Map<String, dynamic> toJson() => _$HeliumHotspotRewardTotalToJson(this);
}
