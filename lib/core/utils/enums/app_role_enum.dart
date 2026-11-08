import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';

/// Who is using the app right now. One app serves both roles.
enum AppRole { admin, technician }

class AppRoleSwitch {
  final AppRole? appRoleEnum;
  final int? appRoleID;

  AppRoleSwitch({this.appRoleEnum, this.appRoleID});

  int switchID() {
    switch (appRoleEnum) {
      case null:
      case AppRole.admin:
        return 1;
      case AppRole.technician:
        return 2;
    }
  }

  AppRole switchEnum() {
    if (appRoleID == 2) return AppRole.technician;
    return AppRole.admin;
  }

  Color getColor() {
    switch (appRoleEnum ?? switchEnum()) {
      case AppRole.admin:
        return AppTheme.primary;
      case AppRole.technician:
        return AppTheme.primary;
    }
  }

  String getText() {
    switch (appRoleEnum ?? switchEnum()) {
      case AppRole.admin:
        return 'Admin'.tr;
      case AppRole.technician:
        return 'Technician'.tr;
    }
  }
}
