import '../../../../core/utils/general_models/g_model_catg.dart';

class ClientModel {
  final String? id;
  final String? name;
  final String? phone;
  final bool? isWhatsAppPhone;
  final String? email;
  final GModelCatg? city;
  final int? ordersCount;
  final num? totalPaid;

  ClientModel(
      {this.id,
      this.name,
      this.phone,
      this.isWhatsAppPhone,
      this.email,
      this.city,
      this.ordersCount,
      this.totalPaid});

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
        id: json['id'] as String?,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        isWhatsAppPhone: json['isWhatsAppPhone'] as bool?,
        email: json['email'] as String?,
        city: json['city'] == null ? null : GModelCatg.fromJson(json['city']),
        ordersCount: json['ordersCount'] as int?,
        totalPaid: json['totalPaid'] as num?);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'isWhatsAppPhone': isWhatsAppPhone,
        'email': email,
        'city': city?.toJson(),
        'ordersCount': ordersCount,
        'totalPaid': totalPaid
      };
}
