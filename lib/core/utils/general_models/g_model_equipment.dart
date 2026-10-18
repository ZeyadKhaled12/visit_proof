class GModelEquipment {
  final String? id;
  final String? name;
  final String? brand;
  final String? model;
  final String? serialNumber;

  GModelEquipment(
      {this.id, this.name, this.brand, this.model, this.serialNumber});

  factory GModelEquipment.fromJson(Map<String, dynamic> json) =>
      GModelEquipment(
          id: json['id'] as String?,
          name: json['name'] as String?,
          brand: json['brand'] as String?,
          model: json['model'] as String?,
          serialNumber: json['serialNumber'] as String?);

  GModelEquipment copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? serialNumber,
  }) {
    return GModelEquipment(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'model': model,
        'serialNumber': serialNumber
      };
}
