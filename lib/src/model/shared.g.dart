// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
