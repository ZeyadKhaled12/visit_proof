import 'package:equatable/equatable.dart';

/// Company-wide dispatch rules the admin can change without code.
class DispatchSettingsModel extends Equatable {
  /// Working day, in minutes after midnight (480 = 08:00).
  final int? workStartMinutes;
  final int? workEndMinutes;

  /// Visits a technician should take per day before a warning shows.
  final int? maxDailyVisits;

  /// Travel gap expected between two visits of the same technician.
  final int? travelBufferMinutes;

  /// True: a technician must have the visit's specialty. False: warning only.
  final bool? strictSkillMatch;

  const DispatchSettingsModel({
    this.workStartMinutes,
    this.workEndMinutes,
    this.maxDailyVisits,
    this.travelBufferMinutes,
    this.strictSkillMatch,
  });

  static const DispatchSettingsModel defaults = DispatchSettingsModel(
    workStartMinutes: 8 * 60,
    workEndMinutes: 18 * 60,
    maxDailyVisits: 6,
    travelBufferMinutes: 30,
    strictSkillMatch: false,
  );

  int get workStart => workStartMinutes ?? defaults.workStartMinutes!;
  int get workEnd => workEndMinutes ?? defaults.workEndMinutes!;
  int get maxVisits => maxDailyVisits ?? defaults.maxDailyVisits!;
  int get travelBuffer => travelBufferMinutes ?? defaults.travelBufferMinutes!;
  bool get strictSkills => strictSkillMatch ?? defaults.strictSkillMatch!;

  factory DispatchSettingsModel.fromJson(Map<String, dynamic> json) {
    return DispatchSettingsModel(
      workStartMinutes: json['workStartMinutes'] as int?,
      workEndMinutes: json['workEndMinutes'] as int?,
      maxDailyVisits: json['maxDailyVisits'] as int?,
      travelBufferMinutes: json['travelBufferMinutes'] as int?,
      strictSkillMatch: json['strictSkillMatch'] as bool?,
    );
  }

  DispatchSettingsModel copyWith({
    int? workStartMinutes,
    int? workEndMinutes,
    int? maxDailyVisits,
    int? travelBufferMinutes,
    bool? strictSkillMatch,
  }) {
    return DispatchSettingsModel(
      workStartMinutes: workStartMinutes ?? this.workStartMinutes,
      workEndMinutes: workEndMinutes ?? this.workEndMinutes,
      maxDailyVisits: maxDailyVisits ?? this.maxDailyVisits,
      travelBufferMinutes: travelBufferMinutes ?? this.travelBufferMinutes,
      strictSkillMatch: strictSkillMatch ?? this.strictSkillMatch,
    );
  }

  Map<String, dynamic> toJson() => {
        'workStartMinutes': workStartMinutes,
        'workEndMinutes': workEndMinutes,
        'maxDailyVisits': maxDailyVisits,
        'travelBufferMinutes': travelBufferMinutes,
        'strictSkillMatch': strictSkillMatch,
      };

  @override
  List<Object?> get props => [
        workStartMinutes,
        workEndMinutes,
        maxDailyVisits,
        travelBufferMinutes,
        strictSkillMatch,
      ];
}
