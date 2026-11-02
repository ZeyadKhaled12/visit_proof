import 'package:visit_proof/configs/app_language.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../features/visits/data/models/visit_detail_models/visit_history_model.dart';
import '../utils/enums/app_role_enum.dart';

/// Who is using the app: the admin, or one signed-in technician.
class AppSessionModel extends Equatable {
  final AppRole? role;
  final String? technicianId;
  final String? technicianName;
  final String? technicianEmail;

  const AppSessionModel(
      {this.role, this.technicianId, this.technicianName, this.technicianEmail});

  factory AppSessionModel.fromJson(Map<String, dynamic> json) {
    return AppSessionModel(
      role: json['role'] == null
          ? null
          : AppRoleSwitch(appRoleID: json['role']).switchEnum(),
      technicianId: json['technicianId'] as String?,
      technicianName: json['technicianName'] as String?,
      technicianEmail: json['technicianEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role == null ? null : AppRoleSwitch(appRoleEnum: role).switchID(),
        'technicianId': technicianId,
        'technicianName': technicianName,
        'technicianEmail': technicianEmail,
      };

  @override
  List<Object?> get props => [role, technicianId, technicianName, technicianEmail];
}

/// The current session, read everywhere and written only by the auth
/// feature (which also saves it under [storageKey]).
///
/// Data sources use it to decide what the caller may do and to sign every
/// history entry with the real actor.
class AppSession {
  AppSession._();

  /// SharedPreferences key of the saved session.
  static const String storageKey = 'session';

  static final ValueNotifier<AppSessionModel?> current = ValueNotifier(null);

  static bool get isSignedIn => current.value?.role != null;
  static bool get isAdmin => current.value?.role == AppRole.admin;
  static bool get isTechnician =>
      current.value?.role == AppRole.technician &&
      current.value?.technicianId != null;

  static String? get technicianId =>
      isTechnician ? current.value?.technicianId : null;

  /// Who to credit in visit history and payment logs.
  static VisitHistoryActorModel get actor => isTechnician
      ? VisitHistoryActorModel(
          id: current.value!.technicianId,
          name: current.value!.technicianName,
          role: 'technician',
        )
      : VisitHistoryActorModel(
          id: 'local-admin',
          name: 'Local Admin'.tr,
          role: 'admin',
        );
}
