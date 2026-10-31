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
      return 'Normal';
    } else if (priorityID == 2) {
      return 'Emergency';
    } else if (priorityID == 3) {
      return 'High';
    } else if (priorityID == 4) {
      return 'Low';
    }

    switch (priorityEnum) {
      case null:
        return 'Normal';
      case Priority.emergency:
        return 'Emergency';
      case Priority.high:
        return 'High';
      case Priority.normal:
        return 'Normal';
      case Priority.low:
        return 'Low';
    }
  }
}
