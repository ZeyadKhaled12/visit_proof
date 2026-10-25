import 'package:equatable/equatable.dart';
import 'package:visit_proof/core/utils/general_models/g_model_equipment.dart';
import 'package:visit_proof/core/utils/general_models/g_model_site.dart';

class VisitClientModel extends Equatable {
  final String? id;
  final String? name;
  final String? phone;
  final bool? isWhatsAppPhone;
  final String? email;
  final List<GModelSite>? sites;
  final List<GModelEquipment>? equipments;

  const VisitClientModel(
      {this.id,
      this.name,
      this.phone,
      this.isWhatsAppPhone,
      this.email,
      this.sites,
      this.equipments});

  factory VisitClientModel.fromJson(Map<String, dynamic> json) {
    return VisitClientModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      isWhatsAppPhone: json['isWhatsAppPhone'] as bool?,
      email: json['email'] as String?,
      sites: (json['sites'] as List<dynamic>?)
          ?.map((e) => GModelSite.fromJson(e as Map<String, dynamic>))
          .toList(),
      equipments: (json['equipments'] as List<dynamic>?)
          ?.map((e) => GModelEquipment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  VisitClientModel copyWith(
      {String? id,
      String? name,
      String? phone,
      bool? isWhatsAppPhone,
      List<GModelSite>? sites,
      String? email,
      List<GModelEquipment>? equipments}) {
    return VisitClientModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        isWhatsAppPhone: isWhatsAppPhone ?? this.isWhatsAppPhone,
        email: email ?? this.email,
        sites: sites ?? this.sites,
        equipments: equipments ?? this.equipments);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'isWhatsAppPhone': isWhatsAppPhone,
      'email': email,
      'sites': sites?.map((e) => e.toJson()).toList(),
      'equipments': equipments?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        isWhatsAppPhone,
        email,
        sites,
        equipments,
      ];
}
