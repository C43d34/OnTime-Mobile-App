
import 'package:flutter/foundation.dart';

/// Represents a geographical point by its longitude and latitude
@immutable
class GeoPoint {
  /// Create [GeoPoint] instance.
  const GeoPoint(this.latitude, this.longitude)
      : assert(latitude >= -90 && latitude <= 90),
        assert(longitude >= -180 && longitude <= 180);

  final double latitude; // ignore: public_member_api_docs
  final double longitude; // ignore: public_member_api_docs

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  GeoPoint.fromJson(Map<String, dynamic> json)
      : latitude = json["latitude"],
        longitude = json["longitude"];

  Map<String, dynamic> toJson() => {
    'latitude' : latitude,
    'longitude' : longitude,
  };

}