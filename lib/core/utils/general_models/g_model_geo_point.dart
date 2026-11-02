import 'package:equatable/equatable.dart';

/// A GPS fix taken from the device: where someone was, how precise the
/// reading was and when it was taken.
class GModelGeoPoint extends Equatable {
  final double? latitude;
  final double? longitude;

  /// Radius of uncertainty in meters.
  final double? accuracy;
  final DateTime? capturedAt;

  const GModelGeoPoint(
      {this.latitude, this.longitude, this.accuracy, this.capturedAt});

  bool get isValid => latitude != null && longitude != null;

  factory GModelGeoPoint.fromJson(Map<String, dynamic> json) {
    return GModelGeoPoint(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      capturedAt: json['capturedAt'] == null
          ? null
          : DateTime.parse(json['capturedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'capturedAt': capturedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [latitude, longitude, accuracy, capturedAt];
}
