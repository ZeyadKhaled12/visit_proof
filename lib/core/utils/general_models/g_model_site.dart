import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';

class GModelSite {
  final GModelCatg? city;
  final String? addressDetail;
  final double? latitude;
  final double? longitude;

  GModelSite({this.city, this.addressDetail, this.latitude, this.longitude});

  factory GModelSite.fromJson(Map<String, dynamic> json) {
    return GModelSite(
      city: json['city'] == null ? null : GModelCatg.fromJson(json['city']),
      addressDetail: json['addressDetail'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  GModelSite copyWith(
      {GModelCatg? city,
      String? addressDetail,
      double? latitude,
      double? longitude}) {
    return GModelSite(
        city: city ?? this.city,
        addressDetail: addressDetail ?? this.addressDetail,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude);
  }

  Map<String, dynamic> toJson() => {
        'city': city?.toJson(),
        'addressDetail': addressDetail,
        'latitude': latitude,
        'longitude': longitude
      };
}
