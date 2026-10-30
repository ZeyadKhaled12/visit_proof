import 'package:equatable/equatable.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';

class ServiceModel extends Equatable {
  final String? id;
  final GModelCatg? category;
  final String? serviceName;
  final num? defaultPrice;
  final int? duration;
  final List<String>? checkList;

  const ServiceModel(
      {this.id,
      this.category,
      this.serviceName,
      this.defaultPrice,
      this.duration,
      this.checkList});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String?,
      category: json['category'] == null
          ? null
          : GModelCatg.fromJson(json['category']),
      serviceName: json['serviceName'] as String?,
      defaultPrice: json['defaultPrice'] as num?,
      duration: json['duration'] as int?,
      checkList: (json['checkList'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  ServiceModel copyWith({
    String? id,
    GModelCatg? category,
    String? serviceName,
    num? defaultPrice,
    int? duration,
    List<String>? checkList,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      category: category ?? this.category,
      serviceName: serviceName ?? this.serviceName,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      duration: duration ?? this.duration,
      checkList: checkList ?? this.checkList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category?.toJson(),
        'serviceName': serviceName,
        'defaultPrice': defaultPrice,
        'duration': duration,
        'checkList': checkList
      };

  @override
  List<Object?> get props =>
      [id, category, serviceName, defaultPrice, duration, checkList];
}
