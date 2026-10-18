import 'package:equatable/equatable.dart';
import 'package:visit_proof/features/clients/data/models/client_model.dart';

import '../../../../../core/utils/general_models/g_model_equipment.dart';
import '../../../../../core/utils/general_models/g_model_site.dart';
import 'client_visit_model.dart';

class ClientDetailModel extends Equatable {
  final String? id;
  final String? name;
  final String? phone;
  final bool? isWhatsAppPhone;
  final String? email;
  final int? ordersCount;
  final num? totalPaid;
  final GModelSite? site;
  final String? notes;
  final DateTime? lastVisit;
  final List<GModelEquipment>? equipments;
  final List<ClientVisitModel>? visits;

  const ClientDetailModel(
      {this.id,
      this.name,
      this.phone,
      this.isWhatsAppPhone,
      this.email,
      this.ordersCount,
      this.totalPaid,
      this.site,
      this.notes,
      this.lastVisit,
      this.equipments,
      this.visits});

  factory ClientDetailModel.fromJson(Map<String, dynamic> json) {
    return ClientDetailModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      isWhatsAppPhone: json['isWhatsAppPhone'] as bool?,
      email: json['email'] as String?,
      ordersCount: json['ordersCount'] as int?,
      totalPaid: json['totalPaid'] as num?,
      site: json['site'] == null ? null : GModelSite.fromJson(json['site']),
      notes: json['notes'] as String?,
      lastVisit: json['lastVisit'] == null
          ? null
          : DateTime.parse(json['lastVisit'] as String),
      equipments: (json['equipments'] as List<dynamic>?)
          ?.map((e) => GModelEquipment.fromJson(e as Map<String, dynamic>))
          .toList(),
      visits: (json['visits'] as List<dynamic>?)
          ?.map((e) => ClientVisitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ClientDetailModel copyWith(
      {String? id,
      String? name,
      String? phone,
      bool? isWhatsAppPhone,
      String? email,
      int? ordersCount,
      num? totalPaid,
      GModelSite? site,
      String? notes,
      DateTime? lastVisit,
      List<GModelEquipment>? equipments,
      List<ClientVisitModel>? visits}) {
    return ClientDetailModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isWhatsAppPhone: isWhatsAppPhone ?? this.isWhatsAppPhone,
      email: email ?? this.email,
      ordersCount: ordersCount ?? this.ordersCount,
      totalPaid: totalPaid ?? this.totalPaid,
      site: site ?? this.site,
      notes: notes ?? this.notes,
      lastVisit: lastVisit ?? this.lastVisit,
      equipments: equipments ?? this.equipments,
      visits: visits ?? this.visits,
    );
  }

  ClientModel convertToClient() => ClientModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      isWhatsAppPhone: isWhatsAppPhone,
      city: site?.city,
      ordersCount: ordersCount,
      totalPaid: totalPaid);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'isWhatsAppPhone': isWhatsAppPhone,
      'email': email,
      'ordersCount': ordersCount,
      'totalPaid': totalPaid,
      'site': site?.toJson(),
      'notes': notes,
      'lastVisit': lastVisit?.toIso8601String(),
      'equipments': equipments?.map((e) => e.toJson()).toList(),
      'visits': visits?.map((e) => e.toJson()).toList()
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        isWhatsAppPhone,
        email,
        ordersCount,
        totalPaid,
        site,
        notes,
        lastVisit,
        equipments,
        visits
      ];
}
