import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

enum Priority { emergency, high, normal, low }

class PrioritySwitch {
  final Priority? priorityEnum;
  final int? priorityID;

  PrioritySwitch({this.priorityEnum, this.priorityID});

  int switchID() {
    switch (priorityEnum) {
      case null:
        return 1;
      case Priority.emergency:
        return 2;
      case Priority.high:
        return 3;
      case Priority.normal:
        return 1;
      case Priority.low:
        return 4;
    }
  }

  Priority switchEnum() {
    if (priorityID == 1) {
      return Priority.normal;
    } else if (priorityID == 2) {
      return Priority.emergency;
    } else if (priorityID == 3) {
      return Priority.high;
    } else if (priorityID == 4) {
      return Priority.low;
    }
    return Priority.normal;
  }

  Color getColor() {
    if (priorityID == 1) {
      return AppTheme.primary;
    } else if (priorityID == 2) {
      return AppTheme.statOrange;
    } else if (priorityID == 3) {
      return AppTheme.secondary;
    } else if (priorityID == 4) {
      return AppTheme.iconGrey;
    }

    switch (priorityEnum) {
      case null:
        return AppTheme.primary;
      case Priority.emergency:
        return AppTheme.statOrange;
      case Priority.high:
        return AppTheme.secondary;
      case Priority.normal:
        return AppTheme.primary;
      case Priority.low:
        return AppTheme.iconGrey;
    }
  }

  String getText() {
    if (priorityID == 1) {
      return 'Normal'.tr;
    } else if (priorityID == 2) {
      return 'Emergency'.tr;
    } else if (priorityID == 3) {
      return 'High'.tr;
    } else if (priorityID == 4) {
      return 'Low'.tr;
    }

    switch (priorityEnum) {
      case null:
        return 'Normal'.tr;
      case Priority.emergency:
        return 'Emergency'.tr;
      case Priority.high:
        return 'High'.tr;
      case Priority.normal:
        return 'Normal'.tr;
      case Priority.low:
        return 'Low'.tr;
    }
  }
}
