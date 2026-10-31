import 'package:equatable/equatable.dart';

/// A day on which a technician cannot receive visits.
class TechnicianDayOffModel extends Equatable {
  final String? technicianId;
  final DateTime? date;

  const TechnicianDayOffModel({this.technicianId, this.date});

  factory TechnicianDayOffModel.fromJson(Map<String, dynamic> json) {
    return TechnicianDayOffModel(
      technicianId: json['technicianId'] as String?,
      date: json['date'] == null
          ? null
          : DateTime.tryParse(json['date'] as String),
    );
  }

  TechnicianDayOffModel copyWith({String? technicianId, DateTime? date}) {
    return TechnicianDayOffModel(
      technicianId: technicianId ?? this.technicianId,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'technicianId': technicianId,
        'date': date?.toIso8601String(),
      };

  /// True when this day off is for [technicianID] on the same calendar day.
  bool covers(String? technicianID, DateTime day) =>
      technicianId == technicianID &&
      date != null &&
      date!.year == day.year &&
      date!.month == day.month &&
      date!.day == day.day;

  @override
  List<Object?> get props => [technicianId, date];
}
