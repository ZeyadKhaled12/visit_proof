class GModelCatg {
  final String? id;
  final String? name;
  final String? description;

  const GModelCatg({this.id, this.name, this.description});

  factory GModelCatg.fromJson(Map<String, dynamic> json) => GModelCatg(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      description: json['description'] as String?);

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'description': description};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GModelCatg && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
