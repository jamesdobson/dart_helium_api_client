import 'package:json_annotation/json_annotation.dart';

part 'shared.g.dart';

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
