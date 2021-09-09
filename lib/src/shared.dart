import 'package:json_annotation/json_annotation.dart';

part 'shared.g.dart';

@JsonSerializable()
class HeliumGeocode {
  /// The long city name, e.g. 'San Francisco' or 'Brookline'
  @JsonKey(name: 'long_city')
  final String? longCity;

  /// The long country name, e.g. 'United States'
  @JsonKey(name: 'long_country')
  final String? longCountry;

  /// The long state name, e.g. 'California' or 'Massachusetts'
  @JsonKey(name: 'long_state')
  final String? longState;

  /// The long street name, e.g. 'Bryant Street' or 'University Road'
  @JsonKey(name: 'long_street')
  final String? longStreet;

  /// The short city name, e.g. 'SF' or 'Brookline'
  @JsonKey(name: 'short_city')
  final String? shortCity;

  /// The short country name, e.g. 'US'
  @JsonKey(name: 'short_country')
  final String? shortCountry;

  /// The short state name, e.g. 'CA' or 'MA'
  @JsonKey(name: 'short_state')
  final String? shortState;

  /// The short street name, e.g. 'Bryant St' or 'University Rd'
  @JsonKey(name: 'short_street')
  final String? shortStreet;

  /// The city id to look up in the cities API.
  ///
  /// e.g. 'c2FuIGZyYW5jaXNjb2NhbGlmb3JuaWF1bml0ZWQgc3RhdGVz' or
  /// 'YnJvb2tsaW5lbWFzc2FjaHVzZXR0c3VuaXRlZCBzdGF0ZXM'.
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
