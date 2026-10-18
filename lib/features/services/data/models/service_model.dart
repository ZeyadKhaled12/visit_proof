import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';

class ServiceModel {
  final GModelCatg? category;
  final String? serviceName;
  final num? defaultPrice;
  final List<String>? checkList;

  ServiceModel(
      {this.category, this.serviceName, this.defaultPrice, this.checkList});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      category: json['category'] == null
          ? null
          : GModelCatg.fromJson(json['category']),
      serviceName: json['serviceName'] as String?,
      defaultPrice: json['defaultPrice'] as num?,
      checkList: (json['checkList'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category?.toJson(),
        'serviceName': serviceName,
        'defaultPrice': defaultPrice,
        'checkList': checkList
      };
}
